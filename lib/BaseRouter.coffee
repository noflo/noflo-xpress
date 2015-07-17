express = require 'express'
uuid = require 'uuid'
noflo = require 'noflo'

validVerbs = ['all', 'get', 'post', 'put', 'delete', 'options']

exports.getComponent = ->
  component = new noflo.Component
  component.description = "Static index-based Express router"
  component.path = '/'
  component.patterns = []
  component.handlers = []

  component.inPorts.add 'app',
    datatype: 'object'
    description: 'Express Application or Router'
    required: true
  component.inPorts.add 'pattern',
    datatype: 'string'
    description: "Request patterns as `verb /path`
    or just `/path` meaning verb is `all`"
    addressable: true
    required: true
  component.outPorts.add 'req',
    datatype: 'object'
    description: 'Express Request objects (contain responses)'
    addressable: true
  component.outPorts.add 'error',
    datatype: 'object'
    required: false

  component

exports.getProcess = (component, hasPath, hasFilter) ->
  (app, groups, out) ->
    unless app
      component.error new Error "Invalid Express app or router"

    for index, pat of component.params.pattern
      pat = pat.split /\s+/
      verb = if pat.length is 2 then pat[0] else 'all'
      path = if pat.length is 2 then pat[1] else pat[0]
      ok = true
      unless validVerbs.indexOf(verb) >= 0
        component.error new Error "Invalid HTTP verb: '#{verb}'"
        ok = false
      unless path
        component.error new Error "Incorrect HTTP path: '#{path}'"
        ok = false
      continue unless ok
      component.patterns[Number index] =
        verb: verb
        path: path

    unless component.patterns.length
      component.error new Error "No route patterns provided"

    component.handlers = []
    router = express.Router()

    # Adding the routes here
    for pat, index in component.patterns
      do (pat, index) ->
        return if pat is undefined
        component.handlers[index] = (req, res, next) ->
          id = uuid()
          req.uuid = id
          res.uuid = id
          component.outPorts.req.beginGroup id, index
          component.outPorts.req.send req, index
          component.outPorts.req.endGroup index
          component.outPorts.req.disconnect index

        func = router[pat.verb]
        if hasFilter and Array.isArray component.params.filters
          for filter in component.params.filters
            func.call router, pat.path, filter
        func.call router, pat.path, component.handlers[index]

    if hasPath and component.params.path
      app.use component.params.path, router
    else
      app.use router
