const noflo = require('noflo');

exports.getComponent = () => {
  const c = new noflo.Component({
    inPorts: {
      req: {
        datatype: 'object',
        control: true,
      },
    },
    outPorts: {
      error: { datatype: 'object' },
    },
  });

  c.forwardBrackets = { filters: ['filters'] };

  return c.process((input, output) => {
    if (!input.hasData('req')) { return; }
    const req = input.getData('req');
    req.res.json('Hello');
    output.done();
  });
};
