noflo = require 'noflo'
BaseRouter = require '../lib/BaseRouter'

exports.getComponent = (metadata) ->
  component = BaseRouter.getComponent()

  noflo.helpers.WirePattern component,
    in: ['app']
    out: []
    params: ['pattern']
  , BaseRouter.getProcess component, false, false
