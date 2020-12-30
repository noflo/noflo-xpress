const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({
    inPorts: {
      app: {
        datatype: 'object',
        description: 'Express Application',
        control: true,
      },
    },
    outPorts: {
      error: {
        datatype: 'object',
      },
      app: {
        datatype: 'object',
        required: true,
        caching: true,
        description: 'Configured Express Application',
      },
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('app')) { return; }
    const app = input.getData('app');

    try {
      // TODO add some middleware here
      c.outPorts.app.send(app);
      c.outPorts.app.disconnect();
    } catch (e) {
      output.done(new Error(`Could not setup server: ${e.message}`));
    }

    output.done();
  });
};
