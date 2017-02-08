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
    data = input.getStream 'in'
    for ip in data
      console.log ip.data if ip.data
    output.done()
