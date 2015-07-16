noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.pass = ''
  c.inPorts.add 'pass', datatype: 'string', (event, payload) ->
    c.pass = payload if event is 'data'
  c.inPorts.add 'new', datatype: 'bang', (event, payload) ->
    return unless event is 'data'
    c.outPorts.filter.send (req, res, next) ->
      if req.get('Pass') is c.pass
        return next()
      else
        return res.sendStatus 403
    c.outPorts.filter.disconnect()
  c.outPorts.add 'filter', datatype: 'function'
  c.outPorts.add 'error', datatype: 'object'

  c
