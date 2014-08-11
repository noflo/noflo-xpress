noflo = require 'noflo'
express = require 'express'
uuid = require 'uuid'

exports.getComponent = (metadata) ->
  component = new noflo.Component
  component.description = "Static index-based Express router"

  validVerbs = ['all', 'get', 'post', 'put', 'delete', 'options']
  component.path = '/'
  component.filters = []
  component.patterns = []
  component.handlers = []

  component.inPorts.add 'app',
    datatype: 'object'
    description: 'Express Application or Router'
    required: true
  component.inPorts.add 'path',
    datatype: 'string'
    description: "Restrict this branch to a specific URL /root"
    required: metadata and 'path' of metadata and metadata.path is 'on'
  component.inPorts.add 'filter',
    datatype: 'function'
    description: 'Route filter middleware (omitted by default)'
    required: metadata and 'filter' of metadata and metadata.filter is 'on'
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
  component.outPorts.add 'router',
    datatype: 'object'
    description: 'Express Router object'
    required: false
  component.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern component,
    in: 'app'
    out: []
    params: ['path', 'filter', 'pattern']
  , (app, groups, out) ->
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

    if typeof component.params.filter is 'function'
      # TODO multiple filters support
      router.use component.params.filter

    # Adding the routes here
    for pat, index in component.patterns
      do (pat, index) ->
        component.handlers.push (req, res, next) ->
          id = uuid()
          req.uuid = id
          res.uuid = id
          component.outPorts.req.beginGroup id, index
          component.outPorts.req.send req, index
          component.outPorts.req.endGroup index
          component.outPorts.req.disconnect index

        router[pat.verb].call router, pat.path, component.handlers[index]

    if component.params.path
      app.use component.params.path, router
    else
      app.use router

    if component.outPorts.router.isAttached()
      component.outPorts.router.send router

  return component
