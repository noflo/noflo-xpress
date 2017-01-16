noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      pass:
        datatype: 'string'
        control: true
      filters:
        datatype: 'array'
    outPorts:
      error: datatype: 'object'
      filters: datatype: 'array'

  c.forwardBrackets =
    filters: ['filters']

  c.process (input, output) ->
    return unless input.hasData 'pass', 'filters'

    pass = input.getData 'pass'
    filters = input.getData 'filters'

    filters = [] unless Array.isArray(filters)

    # Can chain incoming filters
    filters.push (req, res, next) ->
      if req.get('Pass') is pass
        return next()
      else
        return res.sendStatus 403

    c.outPorts.filters.send filters
    c.outPorts.filters.disconnect()
    output.done()
