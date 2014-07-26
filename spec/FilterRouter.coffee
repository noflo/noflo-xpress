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


describe 'An Express server in NoFlo with Routers and Filters', ->
  net = null

  before (done) ->
    noflo.loadFile 'test_graphs/FilterRouter.fbp', (network) ->
      net = network
      done()
  after (done) ->
    net.stop()
    done()

  it 'should support regular GET routes', (done) ->
    options =
      hostname: 'localhost'
      port: 3031
      path: "/hello"
      method: 'GET'
    try
      req = http.request options, (res) ->
        chai.expect(res.statusCode).to.equal 200
        getResultJSON res, (json) ->
          chai.expect(json).to.be.a 'string'
          chai.expect(json).to.equal 'Hello'
          done()
      req.end()
    catch e
      done e

  it 'should support filtered GET routes', (done) ->
    options =
      hostname: 'localhost'
      port: 3031
      path: "/endpoint"
      method: 'GET'
      headers:
        'Pass': 'api'
    try
      req = http.request options, (res) ->
        chai.expect(res.statusCode).to.equal 200
        getResultJSON res, (json) ->
          chai.expect(json).to.be.a 'string'
          chai.expect(json).to.equal 'Hello'
          done()
      req.end()
    catch e
      done e

  it 'should filter unauthorized requests', (done) ->
    options =
      hostname: 'localhost'
      port: 3031
      path: "/endpoint"
      method: 'GET'
    try
      req = http.request options, (res) ->
        chai.expect(res.statusCode).to.equal 403
        done()
      req.end()
    catch e
      done e

  it 'should GET protected grouped routes', (done) ->
    options =
      hostname: 'localhost'
      port: 3031
      path: "/admin/dashboard"
      method: 'GET'
      headers:
        'Pass': 'noflo'
    try
      req = http.request options, (res) ->
        chai.expect(res.statusCode).to.equal 200
        getResultJSON res, (json) ->
          chai.expect(json).to.be.a 'string'
          chai.expect(json).to.equal 'Hello'
          done()
      req.end()
    catch e
      done e

  it 'should POST to protected grouped routes', (done) ->
    newUserEmail = 'john' + uuid.v4().substr(0, 16) + '@example.com'
    reqData = JSON.stringify
      email: newUserEmail
    options =
      hostname: 'localhost'
      port: 3031
      path: "/admin/add-user"
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

  it 'should filter unauthorized requests to grouped routes', (done) ->
    options =
      hostname: 'localhost'
      port: 3031
      path: "/admin/dashboard"
      method: 'GET'
    try
      req = http.request options, (res) ->
        chai.expect(res.statusCode).to.equal 403
        done()
      req.end()
    catch e
      done e
