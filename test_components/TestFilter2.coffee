noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'filters', datatype: 'array', (event, payload) ->
    return unless event is 'data'
    # Can chain incoming filters
    filters = if Array.isArray(payload) then payload else []
    filters.push (req, res, next) ->
      res.set 'X-Foo', 'bar'
      res.set 'X-ID', req.uuid
      next()
    c.outPorts.filters.send filters
    c.outPorts.filters.disconnect()
  c.outPorts.add 'filters', datatype: 'array'
  c.outPorts.add 'error', datatype: 'object'
  c
