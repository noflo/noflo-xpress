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
      error: { datatype: 'object' },
    },
  });

  c.forwardBrackets = { filters: ['filters'] };

  return c.process((input, output) => {
    if (!input.hasData('req')) { return; }
    const req = input.getData('req');
    req.res.json('Hello');
    return output.done();
  });
};
