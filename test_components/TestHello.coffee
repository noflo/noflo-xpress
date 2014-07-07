noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'req', datatype: 'object', (event, payload) ->
    return unless event is 'data'
    payload.res.json 'Hello'
  c.outPorts.add 'error', datatype: 'object'


  return c
