const fs = require('fs');

module.exports = (loader, done) => {
  fs.readdir(`${__dirname}/test_components`, (err, files) => {
    if (err) {
      done(err);
      return;
    }
    files.forEach((file) => {
      const m = file.match(/^(\w+)\.js$/);
      if (!m) { return; }
      const path = `${__dirname}/test_components/${file}`;
      loader.registerComponent('xpress', m[1], path);
    });
    done();
  });
};
