/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');
const express = require('express');
const uuid = require('uuid');

const validVerbs = ['all', 'get', 'post', 'put', 'delete', 'options', 'patch', 'head'];

exports.getComponent = function () {
  const c = new noflo.Component({
    description: 'Static index-based Express router',
    inPorts: {
      app: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#app',
        description: 'Express Application or Router',
        required: true,
        control: true,
      },
      pattern: {
        datatype: 'string',
        description: 'Request patterns as `verb /path` \
or just `/path` meaning verb is `all`',
        addressable: true,
        required: true,
      },
      path: {
        datatype: 'string',
        description: 'Restrict this branch to a specific URL /root',
        control: true,
        default: '/',
      },
      filters: {
        datatype: 'array',
        description: 'Route filter middleware (omitted by default)',
        control: true,
      },
    },
    outPorts: {
      req: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#req',
        description: 'Express Request objects (contains responses)',
        addressable: true,
      },
      error: {
        datatype: 'object',
        required: false,
      },
    },
  });

  return c.process((input, output) => {
    // scoped variables for conditionals
    let filters; let index; let pat; let path; let rootPath; let
      verb;
    let hasPath = false;
    let hasFilter = false;

    // precondition
    if (!input.hasData('app')) { return; }
    if (input.ports.filters.isAttached()) { if (!input.hasData('filters')) { return; } }
    if (input.ports.path.isAttached()) { if (!input.hasData('path')) { return; } }
    // wait for all patterns to arrive
    const receivedPatterns = input.attached('pattern').filter((idx) => input.hasData(['pattern', idx]));
    if (receivedPatterns.length !== input.attached('pattern').length) { return; }

    // if attached, it has a filter
    if (input.ports.filters.isAttached()) {
      hasFilter = true;
      filters = input.getData('filters');
    }

    // if attached, it has a path
    if (input.ports.path.isAttached()) {
      hasPath = true;
      rootPath = input.getData('path');
    }

    // process...
    const patterns = [];
    const handlers = [];
    const app = input.getData('app');

    // put the pattern input array<string>s into objects
    for (index of Array.from(input.attached('pattern'))) {
      pat = input.getData(['pattern', index]);
      pat = pat.split(/\s+/);
      verb = pat.length === 2 ? pat[0] : 'all';
      path = pat.length === 2 ? pat[1] : pat[0];
      if (!(validVerbs.indexOf(verb) >= 0)) {
        return output.done(new Error(`Invalid HTTP verb: '${verb}'`));
      }
      if (!path) {
        return output.done(new Error(`Incorrect HTTP path: '${path}'`));
      }
      patterns[Number(index)] = {
        verb,
        path,
      };
    }

    const router = express.Router();

    // Adding the routes here
    for (index = 0; index < patterns.length; index++) {
      pat = patterns[index];
      (function (pat, index) {
        if (pat === undefined) { return; }

        const id = uuid.v4();
        handlers[index] = (req, res, next) => output.ports.req.send(new noflo.IP('data', req, { scope: id }), index);

        const func = router[pat.verb];
        // Set request uuid
        func.call(router, pat.path, (req, res, next) => {
          req.uuid = id;
          res.uuid = id;
          return next();
        });
        if (hasFilter && Array.isArray(filters)) {
          for (const filter of Array.from(filters)) {
            func.call(router, pat.path, filter);
          }
        }
        return func.call(router, pat.path, handlers[index]);
      }(pat, index));
    }

    if (hasPath && rootPath) {
      app.use(rootPath, router);
    } else {
      app.use(router);
    }
    return output.done();
  });
};
