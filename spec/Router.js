const noflo = require('noflo');
const chai = require('chai');
const http = require('http');
const uuid = require('uuid');

const getResultJSON = function (res, callback) {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      return callback(json);
    } catch (e) {
      throw new Error(`${e.message}. Body:${data}`);
    }
  });
};

describe('A static Express Router in NoFlo', () => {
  let net = null;

  before((done) => {
    noflo.loadFile('test_graphs/RouterTest.fbp', {}, (err, network) => {
      if (err) {
        done(err);
        return;
      }
      net = network;
      done();
    });
  });
  after((done) => {
    net.stop(done);
  });

  describe('for unfiltered routes', () => {
    it('should handle GET', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3032,
        path: '/public/hello',
        method: 'GET',
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 200) {
            done(new Error(`Invalid status code: ${res.statusCode}`));
            return;
          }
          getResultJSON(res, (json) => {
            chai.expect(json).to.be.a('string');
            chai.expect(json).to.equal('Hello');
            done();
          });
        });
        req.end();
      } catch (e) {
        done(e);
      }
    });

    it('should handle POST', (done) => {
      const newUserEmail = `john${uuid.v4().substr(0, 16)}@example.com`;
      const reqData = JSON.stringify({ email: newUserEmail });
      const options = {
        hostname: 'localhost',
        port: 3032,
        path: '/public/world',
        method: 'POST',
        headers: {
          'Content-Length': reqData.length,
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 201) {
            done(new Error(`Invalid status code: ${res.statusCode}`));
            return;
          }
          getResultJSON(res, (json) => {
            chai.expect(json).to.be.an('object');
            chai.expect(json.email).to.be.a('string');
            chai.expect(json.email).to.equal(newUserEmail);
            done();
          });
        });
        req.write(reqData);
        req.end();
      } catch (e) {
        done(e);
      }
    });
  });

  describe('for filtered routes', () => {
    it('should block unauthorized requests', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3032,
        path: '/private/hello',
        method: 'GET',
      };
      try {
        const req = http.request(options, (res) => {
          chai.expect(res.statusCode).to.equal(403);
          done();
        });
        req.end();
      } catch (e) {
        done(e);
      }
    });

    it('should handle GET', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3032,
        path: '/private/hello',
        method: 'GET',
        headers: {
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 200) {
            done(new Error(`Invalid status code: ${res.statusCode}`));
            return;
          }
          getResultJSON(res, (json) => {
            chai.expect(json).to.be.a('string');
            chai.expect(json).to.equal('Hello');
            done();
          });
        });
        req.end();
      } catch (e) {
        done(e);
      }
    });

    it('should handle POST', (done) => {
      const newUserEmail = `john${uuid.v4().substr(0, 16)}@example.com`;
      const reqData = JSON.stringify({ email: newUserEmail });
      const options = {
        hostname: 'localhost',
        port: 3032,
        path: '/private/world',
        method: 'POST',
        headers: {
          'Content-Length': reqData.length,
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 201) {
            done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          getResultJSON(res, (json) => {
            chai.expect(json).to.be.an('object');
            chai.expect(json.email).to.be.a('string');
            chai.expect(json.email).to.equal(newUserEmail);
            done();
          });
        });
        req.write(reqData);
        req.end();
      } catch (e) {
        done(e);
      }
    });
  });
});
