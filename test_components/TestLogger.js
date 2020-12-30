const noflo = require('noflo');

exports.getComponent = () => {
  const c = new noflo.Component({
    description: 'Simply logs everything to the console',
    inPorts: {
      in: {
        datatype: 'all',
        description: 'Data to be logged',
      },
    },
  });

  return c.process((input, output) => {
    if (!input.hasStream('in')) { return; }
    const data = input.getStream('in');
    data.forEach((ip) => {
      // eslint-disable-next-line no-console
      if (ip.data) { console.log(ip.data); }
    });
    output.done();
  });
};
