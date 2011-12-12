Path = require './path'
express = require 'express'
Router = require './server/router'

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
      Caboose.path.config.join('application'),
      Caboose.path.config.join('environments', Caboose.env)
    ]
    next = =>
      return callback() if index is files.length
      try
        files[index++].require() @config, next
      catch e
        return callback(e) unless /Cannot find module/.test(e.message)
        next()
    next()
  
  run_initializers_in_path: (initializers_path, callback) ->
    return callback() unless initializers_path.exists_sync()
    files = initializers_path.readdir_sync()
    index = 0
    next = ->
      return callback() if index is files.length
      try
        files[index++].require() next
      catch e
        return callback(e)
    next()
    
  run_initializers: (callback) ->
    @run_initializers_in_path new Path(__dirname).join('initializers'), (err) =>
      return callback(err) if err?
      @run_initializers_in_path Caboose.path.config.join('initializers'), callback

  initialize: (callback) ->
    return callback() if @_state.initialized
    return @_state.callbacks.push(callback) if @_state.initializing
    
    @_state.initializing = true
    @_state.callbacks = [callback]
    
    @router = new Router()
    @router.parse Caboose.path.config.join('routes').require()
    
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

    middleware = Caboose.path.config.join('middleware').require()
    middleware @http
    
    @http.listen @config.http.port

    for method in @_post_boot
      method this

    callback()
    
  address: ->
    @http.address()
