noflo = require 'noflo'
express = require 'express'

exports.getComponent = (metadata) ->
  component = new noflo.Component
  component.description = "Creates a branch to apply filters
  for a set of routes"

  component.path = '/'
  component.filters = []

  component.inPorts.add 'app',
    datatype: 'object'
    description: 'Express Application or Router'
    required: true
  component.inPorts.add 'path',
    datatype: 'string'
    description: "Restrict this branch to a specific URL /root"
    required: metadata and 'path' of metadata and metadata.path is 'on'
  component.inPorts.add 'filter',
    datatype: 'function'
    description: 'Route filter middleware (omitted by default)'
    required: metadata and 'filter' of metadata and metadata.filter is 'on'
  component.outPorts.add 'router',
    datatype: 'object'
    description: 'Express Router object'
    required: true
  component.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern component,
    in: 'app'
    out: 'router'
    params: ['path', 'filter']
    forwardGroups: true
  , (app, groups, out) ->
    unless app
      component.error new Error 'Invalid Express app or router'

    router = express.Router()

    if typeof component.params.filter is 'function'
      # TODO multiple filters support
      router.use component.params.filter

    if component.params.path
      app.use component.params.path, router
    else
      app.use router
    out.send router

  return component
