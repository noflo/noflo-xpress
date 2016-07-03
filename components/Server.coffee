noflo = require 'noflo'
express = require 'express'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Express HTTP server'
    inPorts:
      port:
        datatype: 'int'
        description: 'Port to start listening on'
    outPorts:
      app:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#app'
        description: 'Express Application'
      error:
        datatype: 'object'

  c.servers = []

  c.shutdown = ->
    for server in c.server
      server._connections = 0
      server.close()

  c.forwardBrackets =
    port: ['app', 'error']

  c.process (input, output) ->
    return unless input.has 'port'
    port = input.getData 'port'

    try
      app = express()
      c.servers[port.scope] = app.listen port
      output.send app: app
      output.done()
    catch e
      return output.done new Error "Cannot listen on port #{port}:#{e.message}"
