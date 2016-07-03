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
        required: true
        control: true
        default: '/'
      filters:
        datatype: 'array'
        description: 'Route filter middleware (omitted by default)'
        required: true
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
    return unless input.has 'app'

    # if attached, it has a filter
    if input.ports.filters.isAttached()
      return unless input.has 'filters'
      hasFilter = true
      filters = input.getData 'filters'

    # if attached, it has a path
    if input.ports.path.isAttached()
      return unless input.has 'path'
      rootPath = input.getData 'path'
      hasPath = true

    # process...
    patterns = []
    handlers = []
    app = input.getData 'app'
    pattern = input.buffer.get 'pattern'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data

    # put the pattern input array<string>s into objects
    for index, pat of pattern
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
        handlers[index] = (req, res, next) ->
          openBracket = new noflo.IP 'openBracket', req.uuid, index: index
          closeBracket = new noflo.IP 'closeBracket', req.uuid, index: index
          output.ports.req.send openBracket, index
          output.ports.req.send req, index
          output.ports.req.send closeBracket, index

        func = router[pat.verb]
        # Set request uuid
        func.call router, pat.path, (req, res, next) ->
          id = uuid.v4()
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

    # clear our buffer state...

    # check if all sockets have been detached
    allDisconnected = true
    if input.ports.pattern.isAttached()
      for socket in input.ports.pattern.sockets
        if socket.isConnected()
          allDisconnected = false

    # if there are as many patterns as sockets
    return unless pattern.length is input.ports.pattern.sockets.length
    return unless allDisconnected

    # go through every pattern, filter them
    for packet, index in input.buffer.get 'pattern'
      input.buffer.filter 'pattern', (ip) ->
        return true if ip.type isnt packet.type
        return true if ip.scope isnt packet.scope
        return true if ip.data isnt packet.data
        return true if ip.index isnt packet.index
        return true if ip.owner isnt packet.owner
        return true if ip.groups isnt packet.groups
        return false
