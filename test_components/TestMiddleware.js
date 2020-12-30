/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
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
      return output.done(new Error(`Could not setup server: ${e.message}`));
    }

    return output.done();
  });
};
