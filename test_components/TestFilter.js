/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');

exports.getComponent = function () {
  const c = new noflo.Component({
    inPorts: {
      pass: {
        datatype: 'string',
        control: true,
      },
      filters: {
        datatype: 'array',
      },
    },
    outPorts: {
      error: { datatype: 'object' },
      filters: { datatype: 'array' },
    },
  });

  c.forwardBrackets = { filters: ['filters'] };

  return c.process((input, output) => {
    if (!input.hasData('pass', 'filters')) { return; }

    const pass = input.getData('pass');
    let filters = input.getData('filters');

    if (!Array.isArray(filters)) { filters = []; }

    // Can chain incoming filters
    filters.push((req, res, next) => {
      if (req.get('Pass') === pass) {
        return next();
      }
      return res.sendStatus(403);
    });

    c.outPorts.filters.send(filters);
    c.outPorts.filters.disconnect();
    return output.done();
  });
};
