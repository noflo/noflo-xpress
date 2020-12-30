/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const noflo = require('noflo');
const chai = require('chai');
const http = require('http');
const uuid = require('uuid');
const express = require('express');

const getResultJSON = function (res, callback) {
  let data = '';
  res.on('data', (chunk) => data += chunk);
  return res.on('end', () => {
    try {
      const json = JSON.parse(data);
      return callback(json);
    } catch (e) {
      throw new Error(`${e.message}. Body:${data}`);
    }
  });
};

describe('A RESTful Resource router', () => {
  let net = null;

  before((done) => {
    noflo.loadFile('test_graphs/ResourceTest.fbp', {}, (err, network) => {
      if (err) { return done(err); }
      net = network;
      return done();
    });
  });
  after((done) => {
    net.stop(done);
  });

  describe('with limited methods and without a filter', () => {
    it('should Index', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/tiny',
        method: 'GET',
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 200) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.a('string');
            chai.expect(json).to.equal('Hello');
            return done();
          });
        });
        return req.end();
      } catch (e) {
        return done(e);
      }
    });

    return it('should Create', (done) => {
      const newUserEmail = `john${uuid.v4().substr(0, 16)}@example.com`;
      const reqData = JSON.stringify({ email: newUserEmail });
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/tiny',
        method: 'POST',
        headers: {
          'Content-Length': reqData.length,
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 201) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.an('object');
            chai.expect(json.email).to.be.a('string');
            chai.expect(json.email).to.equal(newUserEmail);
            return done();
          });
        });
        req.write(reqData);
        return req.end();
      } catch (e) {
        return done(e);
      }
    });
  });

  return describe('for complete REST resource with a filter', () => {
    it('should block unauthorized requests', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/full',
        method: 'GET',
      };
      try {
        const req = http.request(options, (res) => {
          chai.expect(res.statusCode).to.equal(403);
          return done();
        });
        return req.end();
      } catch (e) {
        return done(e);
      }
    });

    it('should Index', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/full',
        method: 'GET',
        headers: {
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 200) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.a('string');
            chai.expect(json).to.equal('Hello');
            return done();
          });
        });
        return req.end();
      } catch (e) {
        return done(e);
      }
    });

    it('should Create', (done) => {
      const newUserEmail = `john${uuid.v4().substr(0, 16)}@example.com`;
      const reqData = JSON.stringify({ email: newUserEmail });
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/full',
        method: 'POST',
        headers: {
          'Content-Length': reqData.length,
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 201) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.an('object');
            chai.expect(json.email).to.be.a('string');
            chai.expect(json.email).to.equal(newUserEmail);
            return done();
          });
        });
        req.write(reqData);
        return req.end();
      } catch (e) {
        return done(e);
      }
    });

    it('should Show', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/full/1',
        method: 'GET',
        headers: {
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 200) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.a('string');
            chai.expect(json).to.equal('Hello');
            return done();
          });
        });
        return req.end();
      } catch (e) {
        return done(e);
      }
    });

    it('should Update', (done) => {
      const newUserEmail = `john${uuid.v4().substr(0, 16)}@example.com`;
      const reqData = JSON.stringify({ email: newUserEmail });
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/full/1',
        method: 'PUT',
        headers: {
          'Content-Length': reqData.length,
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 201) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.an('object');
            chai.expect(json.email).to.be.a('string');
            chai.expect(json.email).to.equal(newUserEmail);
            return done();
          });
        });
        req.write(reqData);
        return req.end();
      } catch (e) {
        return done(e);
      }
    });

    return it('should Destroy', (done) => {
      const options = {
        hostname: 'localhost',
        port: 3033,
        path: '/api/full/1',
        method: 'DELETE',
        headers: {
          Pass: 'noflo',
        },
      };
      try {
        const req = http.request(options, (res) => {
          if (res.statusCode !== 200) {
            return done(new Error(`Invalid status code: ${res.statusCode}`));
          }
          return getResultJSON(res, (json) => {
            chai.expect(json).to.be.a('string');
            chai.expect(json).to.equal('Hello');
            return done();
          });
        });
        return req.end();
      } catch (e) {
        return done(e);
      }
    });
  });
});
