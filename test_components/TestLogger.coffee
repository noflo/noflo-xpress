noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Simply logs everything to the console"
  c.inPorts.add 'in',
    datatype: 'all'
    description: 'Data to be logged'
    proc: (event, payload) ->
      console.log payload if event is 'data'
  c
