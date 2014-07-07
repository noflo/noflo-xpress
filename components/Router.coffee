noflo = require 'noflo'
express = require 'express'

exports.getComponent = ->
  component = new noflo.Component
  component.description = "Creates a branch to apply filters
  for a set of routes"

  component.inPorts.add 'app',
    datatype: 'object'
    description: 'Express Application or Router'
    required: true
    process: (event, app) ->
      return unless event is 'data'
      router = express.Router()
      if component.path
        app.use component.path, router
      else
        app.use router
      component.outPorts.router.send router
      component.outPorts.router.disconnect()

  component.inPorts.add 'path',
    datatype: 'string'
    description: "Restrict this branch to a specific URL /root"
    required: false
    process: (event, payload) ->
      component.path = payload if event is 'data'

  component.outPorts.add 'router',
    datatype: 'object'
    description: 'Express Router object'
    required: true
  component.outPorts.add 'error',
    datatype: 'object'
    required: false

  return component
