noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Simply logs everything to the console'
    inPorts:
      in:
        datatype: 'all'
        description: 'Data to be logged'

  c.process (input, output) ->
    return unless input.hasStream 'in'
    data = input.buffer.get('in')
      .filter (ip) -> ip.type is 'data'
      .pop()

    console.log data if data?
    output.done()
