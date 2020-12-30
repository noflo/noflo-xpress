const noflo = require('noflo');

exports.getComponent = () => {
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
    output.done();
  });
};
