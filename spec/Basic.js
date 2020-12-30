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
      callback(json);
    } catch (e) {
      throw new Error(`${e.message}. Body:${data}`);
    }
  });
};

describe('A basic Express server in NoFlo', () => {
  let net = null;

  before((done) => {
    noflo.loadFile('test_graphs/BasicApp.fbp', {}, (err, network) => {
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

  it('should handle GET', (done) => {
    const options = {
      hostname: 'localhost',
      port: 3030,
      path: '/hello',
      method: 'GET',
    };
    try {
      const req = http.request(options, (res) => getResultJSON(res, (json) => {
        chai.expect(json).to.be.a('string');
        chai.expect(json).to.equal('Hello');
        done();
      }));
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
      port: 3030,
      path: '/world',
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
