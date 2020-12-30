const noflo = require('noflo');

exports.getComponent = () => {
  const c = new noflo.Component({
    inPorts: {
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
    if (!input.hasData('filters')) { return; }

    let filters = input.getData('filters');
    if (!Array.isArray(filters)) { filters = []; }

    // Can chain incoming filters
    filters.push((req, res, next) => {
      res.set('X-Foo', 'bar');
      res.set('X-ID', req.uuid);
      next();
    });

    c.outPorts.filters.send(filters);
    c.outPorts.filters.disconnect();
    output.done();
  });
};
