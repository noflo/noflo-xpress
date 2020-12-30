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
      error: {
        datatype: 'object',
      },
    },
  });

  return c.process((input, output) => {
    if (!input.hasData('req')) { return; }
    const req = input.getData('req');

    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
    });
    req.on('end', () => {
      req.res.status(201).send(data);
      output.done();
    });
  });
};
