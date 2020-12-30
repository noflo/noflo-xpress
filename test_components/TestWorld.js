/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');

exports.getComponent = function () {
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
    req.on('data', (chunk) => data += chunk);
    return req.on('end', () => {
      req.res.status(201).send(data);
      return output.done();
    });
  });
};
