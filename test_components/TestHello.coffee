noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      req:
        datatype: 'object'
        control: true
    outPorts:
      error: datatype: 'object'

  c.forwardBrackets =
    filters: ['filters']

  c.process (input, output) ->
    return unless input.has 'req'
    req = input.getData 'req'
    req.res.json 'Hello'
    output.done()
