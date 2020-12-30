const noflo = require('noflo');
const https = require('https');
const express = require('express');

exports.getComponent = () => {
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

  c.tearDown = (done) => {
    Object.keys(c.servers).forEach((scope) => {
      const server = c.servers[scope];
      server._connections = 0; // eslint-disable-line no-underscore-dangle
      server.close();
    });
    Object.keys(c.context).forEach((scope) => {
      const context = c.context[scope];
      context.deactivate();
    });
    c.servers = {};
    c.context = {};
    done();
  };

  c.forwardBrackets = { port: ['app', 'error'] };

  return c.process((input, output, context) => {
    if (!input.hasData('config', 'port')) { return; }
    const [config, port] = input.getData('config', 'port');

    try {
      const app = express();
      const server = https.createServer(config, app);
      c.context[input.scope] = context;
      c.servers[input.scope] = server.listen(port);
      output.send({ app });
    } catch (e) {
      output.done(new Error(`Cannot listen on port ${port}:${e.message}`));
    }
  });
};
