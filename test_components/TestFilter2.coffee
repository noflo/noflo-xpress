noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      filters:
        datatype: 'array'
    outPorts:
      error: datatype: 'object'
      filters: datatype: 'array'

  c.forwardBrackets =
    filters: ['filters']

  c.process (input, output) ->
    return unless input.has 'filters'

    filters = input.getData 'filters'
    filters = [] unless Array.isArray(filters)

    # Can chain incoming filters
    filters.push (req, res, next) ->
      res.set 'X-Foo', 'bar'
      res.set 'X-ID', req.uuid
      next()

    c.outPorts.filters.send filters
    c.outPorts.filters.disconnect()
    output.done()
