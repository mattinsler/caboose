fs = require 'fs'
path = require 'path'
express = require 'express'
Routes = require './server/routes'
Router = require './server/router'

module.exports = class Application
  constructor: ->
    @_state = {}
    @registry = require './registry'

  configure: (callback) ->
    @config = {}
    index = 0
    files = [
      path.join(Caboose.root, 'config', 'application'),
      path.join(Caboose.root, 'config', 'environments', Caboose.env)
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
        console.log path.join(initializers_path, files[index])
        require(path.join(initializers_path, files[index++])) next
      catch e
        return callback(e)
    next()
    
  run_initializers: (callback) ->
    @run_initializers_in_path path.join(__dirname, 'initializers'), (err) =>
      return callback(err) if err?
      @run_initializers_in_path path.join(Caboose.root, 'config', 'initializers'), callback

  initialize: (callback) ->
    return callback() if @_state.initialized
    return @_state.callbacks.push(callback) if @_state.initializing

    @_state.initializing = true
    @_state.callbacks = [callback]
      
    @configure (err) =>
      if err?
        console.error err.stack
        process.exit 1
      @run_initializers (err) =>
        if err?
          console.error err.stack
          process.exit 1
        c() for c in @_state.callbacks
        @_state.initialized = true
        delete @_state.initializing
        delete @_state.callbacks
    
    # @config = config
    # @http = express.createServer() if config.http
    # 
    # @routes = Routes.create path.join(@paths.config, 'routes.coffee')
    # @router = Router.create @http, @routes
    
  listen: ->
    @http.listen @config.http.port
    
  address: ->
    @http.address()