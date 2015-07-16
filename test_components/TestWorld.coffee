noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'req', datatype: 'object'
  c.outPorts.add 'error', datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'req'
    out: []
    async: true
    forwardGroups: true
  , (req, groups, out, callback) ->
    data = ''
    req.on 'data', (chunk) ->
      data += chunk
    req.on 'end', ->
      req.res.status(201).send data
      callback()
