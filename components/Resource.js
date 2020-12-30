/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');
const express = require('express');
const uuid = require('uuid');

exports.getComponent = function () {
  const c = new noflo.Component({
    description: 'RESTful resource router',
    inPorts: {
      app: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#app',
        description: 'Express Application or Router',
        required: true,
        control: true,
      },
      path: {
        datatype: 'string',
        description: 'Restrict this branch to a specific URL /root',
        control: true,
        default: '/',
        required: true,
      },
      filters: {
        datatype: 'array',
        description: 'Route filter middleware (omitted by default)',
        control: true,
        required: false,
      },
    },
    outPorts: {
      index: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#req',
        description: 'Index requests',
        required: false,
      },
      show: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#req',
        description: 'Show single item requests',
        required: false,
      },
      create: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#req',
        description: 'Create requests',
        required: false,
      },
      update: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#req',
        description: 'Update requests',
        required: false,
      },
      destroy: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#req',
        description: 'Delete requests',
        required: false,
      },
      error: {
        datatype: 'object',
        required: false,
      },
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('app', 'path')) { return; }
    if (input.ports.filters.isAttached()) { if (!input.hasData('filters')) { return; } }

    // if attached, it has a filter
    let hasFilter = false;
    let filters = [];
    if (input.ports.filters.isAttached()) {
      hasFilter = true;
      filters = input.getData('filters');
    }

    const app = input.getData('app');
    const rootPath = input.getData('path');

    const sendReq = function (port, req) {
      const map = {};
      map[port] = new noflo.IP('data', req, { scope: uuid.v4() });
      return output.send(map);
    };

    const mountMethod = function (router, port, verb) {
      if (!c.outPorts[port].isAttached()) { return router; }
      return router[verb].call(router, (req, res, next) => sendReq(port, req));
    };

    const router = express.Router();
    if (hasFilter && Array.isArray(filters)) {
      for (const filter of Array.from(filters)) {
        router.use(filter);
      }
    }

    const root = router.route(rootPath);
    mountMethod(root, 'index', 'get');
    mountMethod(root, 'create', 'post');

    const item = router.route(`${rootPath}/:id`);
    mountMethod(item, 'show', 'get');
    mountMethod(item, 'update', 'put');
    mountMethod(item, 'update', 'patch');
    mountMethod(item, 'destroy', 'delete');

    app.use(router);
    return output.done();
  });
};
