_ = require 'underscore'
Path = require './path'
express = require 'express'
Router = require './server/router'

module.exports = class Application
  constructor: (@name) ->
    @_state = {}
    @_post_boot = []
    @registry = require './registry'

  post_boot: (method) ->
    @_post_boot.push method
  
  read_config_files: (config) ->
    files = Caboose.path.config.readdir_sync()
    env_dir = Caboose.path.config.join('environments', Caboose.env)
    files = files.concat(env_dir.readdir_sync()) if env_dir.exists_sync() and env_dir.is_directory_sync()

    for file in files
      if file.extension is 'json'
        config[file.basename] = JSON.parse(file.read_file_sync('utf8'))

  configure: (callback) ->
    @config = {}
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
  
  load_plugins: ->
    package = JSON.parse(Caboose.root.join('package.json').read_file_sync('utf8'))
    @plugins = package['caboose-plugins']
    if @plugins?
      for p in @plugins
        plugin = require(p)
        throw new Error("#{p} is not a caboose plugin".red) unless plugin['caboose-plugin']?
        if plugin['caboose-plugin'].initialize?
          plugin['caboose-plugin'].initialize()
  
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
    
    @_state.initializing = true
    @_state.callbacks = [callback]
    
    @router = new Router()
    @router.parse Caboose.path.config.join('routes').require()
    @configure (err) =>
      if err?
        console.error err.stack
        process.exit 1
      @load_plugins()
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

  load_models: ->
    models = []
    if Caboose.path.models.exists_sync()
      for file in Caboose.path.models.readdir_sync()
        models.push(Caboose.registry.get(file.basename)) if file.extension in ['js', 'coffee']
    models
  
  address: ->
    @http.address()
