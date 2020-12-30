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

describe('A basic Express server in NoFlo', () => {
  let net = null;

  before((done) => {
    noflo.loadFile('test_graphs/BasicApp.fbp', {}, (err, network) => {
      if (err) { return done(err); }
      net = network;
      return done();
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
        return done();
      }));
      return req.end();
    } catch (e) {
      return done(e);
    }
  });

  return it('should handle POST', (done) => {
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
