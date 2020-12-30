/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');
const fs = require('fs');

module.exports = function (loader, done) {
  const dirs = [
    'test_components',
    'components',
  ];
  for (const dir of Array.from(dirs)) {
    for (const file of Array.from(fs.readdirSync(`${__dirname}/${dir}`))) {
      const m = file.match(/^(\w+)\.coffee$/);
      if (!m) { continue; }
      const path = `${__dirname}/${dir}/${file}`;
      loader.registerComponent('xpress', m[1], path);
    }
  }
  return done();
};
