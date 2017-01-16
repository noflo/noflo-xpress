noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      app:
        datatype: 'object'
        description: 'Express Application'
        control: true
    outPorts:
      error:
        datatype: 'object'
      app:
        datatype: 'object'
        required: true
        caching: true
        description: 'Configured Express Application'

  c.process (input, output) ->
    return unless input.hasData 'app'
    app = input.getData 'app'

    try
      # TODO add some middleware here
      c.outPorts.app.send app
      c.outPorts.app.disconnect()
    catch e
      return output.done new Error "Could not setup server: #{e.message}"

    output.done()
