noflo = require 'noflo'
express = require 'express'

exports.getComponent = ->
  component = new noflo.Component
  component.description = "Express HTTP server"

  component.inPorts.add 'port',
    datatype: 'int'
    description: 'Port to start listening on'
  , (event, port) ->
    return unless event is 'data'
    try
      component.app = express()
      component.app.listen port
      component.outPorts.app.send component.app
      component.outPorts.app.disconnect()
    catch e
      return component.error new Error "Cannot listen on port #{port}:
      #{e.message}"

  component.outPorts.add 'app',
    datatype: 'object'
    required: true
    description: "Express Application"
  component.outPorts.add 'error', datatype: 'object'

  return component
