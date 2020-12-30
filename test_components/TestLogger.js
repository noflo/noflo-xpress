/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');

exports.getComponent = function () {
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
    for (const ip of Array.from(data)) {
      if (ip.data) { console.log(ip.data); }
    }
    return output.done();
  });
};
