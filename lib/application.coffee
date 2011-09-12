fs = require 'fs'
path = require 'path'
express = require 'express'
Route = require './server/route'
Routes = require './server/routes'

module.exports = class Application
  constructor: ->
    @_state = {}
    @_post_boot = []
    @registry = require './registry'

  post_boot: (method) ->
    @_post_boot.push method

  configure: (callback) ->
    @config = {}
    index = 0
    files = [
      path.join(Caboose.path.config, 'application'),
      path.join(Caboose.path.config, 'environments', Caboose.env)
    ]
    next = =>
      return callback() if index is files.length
      try
        require(files[index++]) @config, next
      catch e
        return callback(e) unless /Cannot find module/.test(e.message)
        next()
    next()
  
  run_initializers_in_path: (initializers_path, callback) ->
    return callback() unless path.existsSync initializers_path
    files = fs.readdirSync initializers_path
    index = 0
    next = ->
      return callback() if index is files.length
      try
        require(path.join(initializers_path, files[index++])) next
      catch e
        return callback(e)
    next()
    
  run_initializers: (callback) ->
    @run_initializers_in_path path.join(__dirname, 'initializers'), (err) =>
      return callback(err) if err?
      @run_initializers_in_path path.join(Caboose.path.config, 'initializers'), callback

  initialize: (callback) ->
    return callback() if @_state.initialized
    return @_state.callbacks.push(callback) if @_state.initializing
    
    @_state.initializing = true
    @_state.callbacks = [callback]
    
    @routes = Routes.create path.join(Caboose.path.config, 'routes')
    
    @configure (err) =>
      if err?
        console.error err.stack
        process.exit 1
      @run_initializers (err) =>
        if err?
          console.error err.stack
          process.exit 1
        c(this) for c in @_state.callbacks
        @_state.initialized = true
        delete @_state.initializing
        delete @_state.callbacks
  
  # boot the web engine
  boot: (callback) ->
    return callback() if not @config.http.enabled
    @http = express.createServer()
    
    middleware = require path.join(Caboose.path.config, 'middleware')
    middleware @http
    
    add_route = (route) =>
      path = route.path
      path += '.:format?' unless path[path.length - 1] is '/'
      # console.log "#{route.method} #{path}"
      @http[route.method] path, (req, res, next) ->
        route.respond req, res, next

    for k, spec of @routes
      route = new Route spec
      add_route route if route?

    @http.listen @config.http.port

    for method in @_post_boot
      method this

    callback()
    
  address: ->
    @http.address()