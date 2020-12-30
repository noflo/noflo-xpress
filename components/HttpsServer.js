/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');
const https = require('https');
const express = require('express');

exports.getComponent = function () {
  const c = new noflo.Component({
    description: 'Express HTTPS server',
    inPorts: {
      config: {
        datatype: 'object',
        description: 'Node.js TLS server configuration',
      },
      port: {
        datatype: 'int',
        description: 'Port to start listening on',
      },
    },
    outPorts: {
      app: {
        datatype: 'object',
        type: 'http://expressjs.com/4x/api.html#app',
        description: 'Express Application',
      },
      error: {
        datatype: 'object',
      },
    },
  });

  c.autoOrdering = false;
  c.servers = {};
  c.context = {};

  c.tearDown = function (done) {
    let context; let
      scope;
    for (scope in c.servers) {
      const server = c.servers[scope];
      server._connections = 0;
      server.close();
    }
    for (scope in c.context) {
      context = c.context[scope];
      context.deactivate();
    }
    c.servers = {};
    c.context = {};
    return done();
  };

  c.forwardBrackets = { port: ['app', 'error'] };

  return c.process((input, output, context) => {
    if (!input.hasData('config', 'port')) { return; }
    const [config, port] = Array.from(input.getData('config', 'port'));

    try {
      const app = express();
      const server = https.createServer(config, app);
      c.context[input.scope] = context;
      c.servers[input.scope] = server.listen(port);
      return output.send({ app });
    } catch (e) {
      return output.done(new Error(`Cannot listen on port ${port}:${e.message}`));
    }
  });
};
