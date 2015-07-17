noflo = require 'noflo'
BaseRouter = require '../lib/BaseRouter'

exports.getComponent = ->
  component = BaseRouter.getComponent()
  component.inPorts.add 'filters',
    datatype: 'array'
    description: 'Route filter middleware (omitted by default)'
    required: true

  noflo.helpers.WirePattern component,
    in: ['app']
    out: []
    params: ['filters', 'pattern']
  , BaseRouter.getProcess component, false, true
