noflo = require 'noflo'
bodyParser = require 'body-parser'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Express body parser middleware'
  c.inPorts.add 'app',
    datatype: 'object'
    type: 'http://expressjs.com/4x/api.html#app'
    description: 'Express Application or Router'
    required: true
  c.inPorts.add 'limit',
    datatype: 'string'
    description: 'Size limit for parsed body'
    required: false
    default: '1mb'
  c.outPorts.add 'app',
    datatype: 'object'
    type: 'http://expressjs.com/4x/api.html#app'
    description: 'Express Application or Router'
    required: true

  c.forwardBrackets =
    app: ['app']

  c.process (input, output) ->
    return unless input.hasData 'app'
    limit = if input.hasData('limit') then input.getData('limit') else '1mb'

    app = input.getData 'app'
    app.use bodyParser.json
      limit: limit

    output.sendDone
      app: app
