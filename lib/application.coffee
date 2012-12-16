_ = require 'underscore'
Path = require './path'
express = require 'express'
Router = require './server/router'
Plugins = require './plugins'

module.exports = class Application
  constructor: (@name) ->
    @_state = {}
    @_after = {}
    @_before = {}
    @registry = require './registry'
  
  _apply_after: (method_name) ->
    method(this) for method in @_after[method_name] if @_after[method_name]
  _apply_before: (method_name) ->
    method(this) for method in @_before[method_name] if @_before[method_name]

  after: (method_name, callback) ->
    (@_after[method_name] ?= []).push callback

  before: (method_name, callback) ->
    (@_before[method_name] ?= []).push callback
  
  read_config_files: (config) ->
    files = Caboose.path.config.readdir_sync()
    env_dir = Caboose.path.config.join('environments', Caboose.env)
    files = files.concat(env_dir.readdir_sync()) if env_dir.exists_sync() and env_dir.is_directory_sync()

    for file in files
      switch file.extension
        when 'json' then config[file.basename] = require('vm').runInThisContext('__xyna8277ghouehsf97g9w3f__ = ' + file.read_file_sync('utf8'), file.path)
        when 'yml', 'yaml' then config[file.basename] = require('yaml').eval(file.read_file_sync('utf8'))

  configure: (callback) ->
    @config = {
      http: {
        enabled: true
        port: process.env.PORT
      }
      controller: require('./controller/builder').config
    }
    _(@config).extend(@plugins.config())
    
    try
      @read_config_files @config
    catch e
      return callback(e)
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
        initializer = files[index++].require()
        if initializer? and typeof initializer is 'function' then initializer(next) else next()
      catch e
        return callback(e)
    next()
    
  run_initializers: (callback) ->
    @run_initializers_in_path Caboose.path.config.join('initializers'), callback

  initialize: (callback) ->
    return callback() if @_state.initialized
    return @_state.callbacks.push(callback) if @_state.initializing
    
    @_apply_before 'initialize'
    
    @_state.initializing = true
    @_state.callbacks = [callback]
    
    @plugins = new Plugins()
    @plugins.load()
    
    @router = new Router()
    @router.parse Caboose.path.config.join('routes').require()
    @configure (err) =>
      if err?
        console.error err.stack
        process.exit 1
      @plugins.initialize()
      @run_initializers (err) =>
        if err?
          console.error(err.stack)
          process.exit(1)
        
        @_apply_after('initialize')
        @_state.initialized = true
        delete @_state.initializing
        
        c(this) for c in @_state.callbacks
        delete @_state.callbacks

  # boot the web engine
  boot: (callback) ->
    return callback() if not @config.http.enabled
    @_apply_before 'boot'
    @http = express()
    
    middleware = Caboose.path.config.join('middleware').require()
    middleware @http
    
    if Caboose.env is 'production'
      @http.use express.errorHandler(dumpExceptions: true)
    else
      @http.use express.errorHandler(showStack: true, dumpExceptions: true)
    
    @raw_http = @http.listen @config.http.port, =>
      throw new Error("Could not listen on port #{@config.http.port}") unless @raw_http.address()

      @_apply_after 'boot'

      callback()

  address: ->
    @raw_http.address()
