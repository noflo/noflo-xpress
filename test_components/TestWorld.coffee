noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      req:
        datatype: 'object'
        control: true
    outPorts:
      error:
        datatype: 'object'

  c.process (input, output) ->
    return unless input.hasData 'req'
    req = input.getData 'req'

    data = ''
    req.on 'data', (chunk) ->
      data += chunk
    req.on 'end', ->
      req.res.status(201).send data
      output.done()
