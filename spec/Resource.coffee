noflo = require 'noflo'
chai = require 'chai'
http = require 'http'
uuid = require 'uuid'
express = require 'express'

getResultJSON = (res, callback) ->
  data = ''
  res.on 'data', (chunk) ->
    data += chunk
  res.on 'end', ->
    try
      json = JSON.parse data
      callback json
    catch e
      throw new Error e.message + ". Body:" + data

describe 'A RESTful Resource router', ->
  net = null

  before (done) ->
    noflo.loadFile 'test_graphs/ResourceTest.fbp', {}, (err, network) ->
      return done err if err
      net = network
      done()
    return
  after (done) ->
    net.stop done
    return

  describe 'with limited methods and without a filter', ->
    it 'should Index', (done) ->
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/tiny"
        method: 'GET'
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 200
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.a 'string'
            chai.expect(json).to.equal 'Hello'
            done()
        req.end()
      catch e
        done e

    it 'should Create', (done) ->
      newUserEmail = 'john' + uuid.v4().substr(0, 16) + '@example.com'
      reqData = JSON.stringify
        email: newUserEmail
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/tiny"
        method: 'POST'
        headers:
          'Content-Length': reqData.length
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 201
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.an 'object'
            chai.expect(json.email).to.be.a 'string'
            chai.expect(json.email).to.equal newUserEmail
            done()
        req.write reqData
        req.end()
      catch e
        done e

  describe 'for complete REST resource with a filter', ->
    it 'should block unauthorized requests', (done) ->
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/full"
        method: 'GET'
      try
        req = http.request options, (res) ->
          chai.expect(res.statusCode).to.equal 403
          done()
        req.end()
      catch e
        done e

    it 'should Index', (done) ->
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/full"
        method: 'GET'
        headers:
          'Pass': 'noflo'
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 200
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.a 'string'
            chai.expect(json).to.equal 'Hello'
            done()
        req.end()
      catch e
        done e

    it 'should Create', (done) ->
      newUserEmail = 'john' + uuid.v4().substr(0, 16) + '@example.com'
      reqData = JSON.stringify
        email: newUserEmail
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/full"
        method: 'POST'
        headers:
          'Content-Length': reqData.length
          'Pass': 'noflo'
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 201
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.an 'object'
            chai.expect(json.email).to.be.a 'string'
            chai.expect(json.email).to.equal newUserEmail
            done()
        req.write reqData
        req.end()
      catch e
        done e

    it 'should Show', (done) ->
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/full/1"
        method: 'GET'
        headers:
          'Pass': 'noflo'
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 200
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.a 'string'
            chai.expect(json).to.equal 'Hello'
            done()
        req.end()
      catch e
        done e

    it 'should Update', (done) ->
      newUserEmail = 'john' + uuid.v4().substr(0, 16) + '@example.com'
      reqData = JSON.stringify
        email: newUserEmail
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/full/1"
        method: 'PUT'
        headers:
          'Content-Length': reqData.length
          'Pass': 'noflo'
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 201
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.an 'object'
            chai.expect(json.email).to.be.a 'string'
            chai.expect(json.email).to.equal newUserEmail
            done()
        req.write reqData
        req.end()
      catch e
        done e

    it 'should Destroy', (done) ->
      options =
        hostname: 'localhost'
        port: 3033
        path: "/api/full/1"
        method: 'DELETE'
        headers:
          'Pass': 'noflo'
      try
        req = http.request options, (res) ->
          if res.statusCode isnt 200
            return done new Error "Invalid status code: #{res.statusCode}"
          getResultJSON res, (json) ->
            chai.expect(json).to.be.a 'string'
            chai.expect(json).to.equal 'Hello'
            done()
        req.end()
      catch e
        done e
