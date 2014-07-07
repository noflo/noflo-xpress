noflo = require 'noflo'

exports.getComponent = ->
  component = new noflo.Component
  component.description = "Configures the Express app"

  component.inPorts.add 'app',
    datatype: 'object'
    description: 'Express Application'
  , (event, app) ->
    return unless event is 'data'
    try
      # TODO add some middleware here
      component.outPorts.app.send app
      component.outPorts.app.disconnect()
    catch e
      return component.error new Error "Could not setup server: #{e.message}"

  component.outPorts.add 'app',
    datatype: 'object'
    required: true
    caching: true
    description: 'Configured Express Application'
  component.outPorts.add 'error', datatype: 'object'

  return component
