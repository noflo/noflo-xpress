noflo = require 'noflo'
express = require 'express'
uuid = require 'uuid'

exports.getComponent = ->
  c = new noflo.Component
    description: 'RESTful resource router'
    inPorts:
      app:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#app'
        description: 'Express Application or Router'
        required: true
        control: true
      path:
        datatype: 'string'
        description: 'Restrict this branch to a specific URL /root'
        control: true
        default: '/'
        required: true
      filters:
        datatype: 'array'
        description: 'Route filter middleware (omitted by default)'
        control: true
        required: false
    outPorts:
      index:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#req'
        description: 'Index requests'
        required: false
      show:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#req'
        description: 'Show single item requests'
        required: false
      create:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#req'
        description: 'Create requests'
        required: false
      update:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#req'
        description: 'Update requests'
        required: false
      destroy:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#req'
        description: 'Delete requests'
        required: false
      error:
        datatype: 'object'
        required: false

  c.process (input, output) ->
    return unless input.hasData 'app', 'path'
    return unless input.hasData 'filters' if input.ports.filters.isAttached()

    # if attached, it has a filter
    hasFilter = false
    filters = []
    if input.ports.filters.isAttached()
      hasFilter = true
      filters = input.getData 'filters'

    app = input.getData 'app'
    rootPath = input.getData 'path'

    sendReq = (port, req) ->
      map = {}
      map[port] = new noflo.IP 'data', req, scope: uuid.v4()
      output.send map

    mountMethod = (router, port, verb) ->
      return router unless c.outPorts[port].isAttached()
      router[verb].call router, (req, res, next) ->
        sendReq port, req

    router = express.Router()
    if hasFilter and Array.isArray filters
      for filter in filters
        router.use filter

    root = router.route rootPath
    mountMethod root, 'index', 'get'
    mountMethod root, 'create', 'post'

    item = router.route "#{rootPath}/:id"
    mountMethod item, 'show', 'get'
    mountMethod item, 'update', 'put'
    mountMethod item, 'update', 'patch'
    mountMethod item, 'destroy', 'delete'

    app.use router
    output.done()
