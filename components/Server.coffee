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

  c.autoOrdering = false
  c.servers = {}
  c.context = {}

  c.tearDown = (done) ->
    for scope, server of c.servers
      server._connections = 0
      server.close()
    for scope, context of c.context
      context.deactivate()
    c.servers = {}
    c.context = {}
    done()

  c.forwardBrackets =
    port: ['app', 'error']

  c.process (input, output, context) ->
    return unless input.hasData 'port'
    port = input.getData 'port'

    try
      app = express()
      c.context[input.scope] = context
      c.servers[input.scope] = app.listen port
      output.send app: app
    catch e
      return output.done new Error "Cannot listen on port #{port}:#{e.message}"
