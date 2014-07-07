noflo = require 'noflo'
uuid = require 'uuid'

exports.getComponent = ->
  component = new noflo.Component
  component.description = "Creates a request route on the application graph"

  validVerbs = ['all', 'get', 'post', 'put', 'delete']
  component.verb = 'all'
  component.path = '/'
  component.filters = []

  component.inPorts.add 'app',
    datatype: 'object'
    description: 'Express Application or Router'
    required: true
  component.inPorts.add 'pattern',
    datatype: 'string'
    description: "Request pattern as `verb /path`
    or just `/path` meaning verb is `all`"
    required: true
  component.inPorts.add 'filter',
    datatype: 'function'
    description: 'Route filter middleware (omitted by default)'
    required: true
    default: null
    process: (event, payload) ->
      return unless event is 'data'
      component.filters.push payload if payload isnt null

  component.outPorts.add 'req',
    datatype: 'object'
    description: 'Express Request object (contains response too)'
    required: true
  component.outPorts.add 'res',
    datatype: 'object'
    description: 'Express Response object (optional)'
    required: false
  component.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.MultiError component, 'Route'

  noflo.helpers.WirePattern component,
    in: 'app'
    out: ['req', 'res']
    params: ['pattern']
    async: true
    forwardGroups: true
  , (app, groups, outs, callback) ->
    unless app
      component.error new Error 'Invalid Express app or router'
    pat = component.params.pattern.split /\s+/
    component.verb = if pat.length is 2 then pat[0] else 'all'
    component.path = if pat.length is 2 then pat[1] else pat[0]
    unless validVerbs.indexOf(component.verb) >= 0
      component.error new Error "Invalid HTTP verb: '#{component.verb}'"
    unless component.path
      component.error new Error "Incorrect HTTP path: '#{component.path}'"
    return callback no if component.hasErrors

    requestHandler = (req, res, next) ->
      id = uuid()
      req.uuid = id
      res.uuid = id

      outs.req.beginGroup id
      outs.req.send req
      outs.req.endGroup()
      # we don't call callback() here so we have to disconnect()
      outs.req.disconnect()

      if outs.res.isAttached()
        outs.res.beginGroup id
        outs.res.send res
        outs.res.endGroup()
        # we don't call callback() here so we have to disconnect()
        outs.res.disconnect()

    func = app[component.verb]
    args = [ component.path ]
      .concat component.filters
      .concat [ requestHandler ]

    func.apply app, args

    callback()

  return component
