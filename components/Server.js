const noflo = require('noflo');
const express = require('express');

exports.getComponent = () => {
  const c = new noflo.Component({
    description: 'Express HTTP server',
    inPorts: {
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
    if (!input.hasData('port')) { return; }
    const port = input.getData('port');

    try {
      const app = express();
      c.context[input.scope] = context;
      c.servers[input.scope] = app.listen(port);
      output.send({ app });
    } catch (e) {
      output.done(new Error(`Cannot listen on port ${port}:${e.message}`));
    }
  });
};
