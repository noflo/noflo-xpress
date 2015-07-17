noflo = require 'noflo'
BaseRouter = require '../lib/BaseRouter'

exports.getComponent = ->
  component = BaseRouter.getComponent()
  component.inPorts.add 'path',
    datatype: 'string'
    description: "Restrict this branch to a specific URL /root"
    required: true
  .add 'filters',
    datatype: 'array'
    description: 'Route filter middleware (omitted by default)'
    required: true

  noflo.helpers.WirePattern component,
    in: ['app']
    out: []
    params: ['path', 'filters', 'pattern']
  , BaseRouter.getProcess component, true, true
