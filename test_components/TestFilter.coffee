noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.pass = ''
  c.inPorts.add 'pass', datatype: 'string', (event, payload) ->
    c.pass = payload if event is 'data'
  c.inPorts.add 'filters', datatype: 'array', (event, payload) ->
    return unless event is 'data'
    # Can chain incoming filters
    filters = if Array.isArray(payload) then payload else []
    filters.push (req, res, next) ->
      if req.get('Pass') is c.pass
        return next()
      else
        return res.sendStatus 403
    c.outPorts.filters.send filters
    c.outPorts.filters.disconnect()
  c.outPorts.add 'filters', datatype: 'array'
  c.outPorts.add 'error', datatype: 'object'

  c
