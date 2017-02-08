noflo = require 'noflo'
express = require 'express'
uuid = require 'uuid'

validVerbs = ['all', 'get', 'post', 'put', 'delete', 'options', 'patch', 'head']

exports.getComponent = ->
  c = new noflo.Component
    description: 'Static index-based Express router'
    inPorts:
      app:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#app'
        description: 'Express Application or Router'
        required: true
        control: true
      pattern:
        datatype: 'string'
        description: 'Request patterns as `verb /path`
        or just `/path` meaning verb is `all`'
        addressable: true
        required: true
      path:
        datatype: 'string'
        description: 'Restrict this branch to a specific URL /root'
        control: true
        default: '/'
      filters:
        datatype: 'array'
        description: 'Route filter middleware (omitted by default)'
        control: true
    outPorts:
      req:
        datatype: 'object'
        type: 'http://expressjs.com/4x/api.html#req'
        description: 'Express Request objects (contain responses)'
        addressable: true
      error:
        datatype: 'object'
        required: false

  c.process (input, output) ->
    # scoped variables for conditionals
    hasPath = false
    hasFilter = false

    # precondition
    return unless input.hasData 'app'
    return unless input.hasData 'filters' if input.ports.filters.isAttached()
    return unless input.hasData 'path' if input.ports.path.isAttached()
    # wait for all patterns to arrive
    receivedPatterns = input.attached('pattern').filter (idx) ->
      input.hasData ['pattern', idx]
    return unless receivedPatterns.length is input.attached('pattern').length

    # if attached, it has a filter
    if input.ports.filters.isAttached()
      hasFilter = true
      filters = input.getData 'filters'

    # if attached, it has a path
    if input.ports.path.isAttached()
      hasPath = true
      rootPath = input.getData 'path'

    # process...
    patterns = []
    handlers = []
    app = input.getData 'app'

    # put the pattern input array<string>s into objects
    for index in input.attached 'pattern'
      pat = input.getData ['pattern', index]
      pat = pat.split /\s+/
      verb = if pat.length is 2 then pat[0] else 'all'
      path = if pat.length is 2 then pat[1] else pat[0]
      unless validVerbs.indexOf(verb) >= 0
        return output.done new Error "Invalid HTTP verb: '#{verb}'"
      unless path
        return output.done new Error "Incorrect HTTP path: '#{path}'"
      patterns[Number index] =
        verb: verb
        path: path

    router = express.Router()

    # Adding the routes here
    for pat, index in patterns
      do (pat, index) ->
        return if pat is undefined

        id = uuid.v4()
        handlers[index] = (req, res, next) ->
          output.ports.req.send new noflo.IP('data', req, scope: id), index

        func = router[pat.verb]
        # Set request uuid
        func.call router, pat.path, (req, res, next) ->
          req.uuid = id
          res.uuid = id
          next()
        if hasFilter and Array.isArray filters
          for filter in filters
            func.call router, pat.path, filter
        func.call router, pat.path, handlers[index]

    if hasPath and rootPath
      app.use rootPath, router
    else
      app.use router
    output.done()

