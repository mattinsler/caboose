path = require 'path'
Application = require './lib/application'

exports.Model = require './lib/model/model'
exports.get = (name) ->
  require('./lib/paths').get('./app')
  require('./lib/registry').get name

create_and_initialize_app = (options, callback) ->
  next = ->
    app.initialize config
    callback app

  app = new Application()
  global.app = app
  app.paths = require('./lib/paths').get('./app')

  # read config
  config = {}
  applicationConfig = require path.join app.paths.config, 'application'
  if applicationConfig?
    applicationConfig config, next
  else
    next()

exports.start = (run_path, options) ->
  create_and_initialize_app options, (app) ->
    app.listen()
    console.log "Listening on port #{app.address().port}"

exports.test = (run_path, options) ->
  vows = require 'vows'
  create_and_initialize_app options, (app) ->
    if options._.length > 0
      require path.join(app.paths.test, name) for name in options._
      vows.suites[0].run {}, -> process.exit()

exports.run = (run_path, options) ->
  return console.log 'USAGE: caboose run script_filename' if options._.length isnt 1
  return console.log "ERROR: Could not find file #{options._[0]}" unless path.existsSync options._[0]
  create_and_initialize_app options, (app) ->
    require options._[0]

exports.console = (run_path, options) ->
  return console.log 'USAGE: caboose console' if options._.length isnt 0
  create_and_initialize_app options, (app) ->
    repl = require 'repl'
    repl.start()
    # console.log repl

exports.routes = (run_path, options) ->
  create_and_initialize_app options, (app) ->
    r = []
    for k, route of app.routes.routes
      r.push route
    cliff = require 'cliff'
    # console.log r
    console.log cliff.stringifyObjectRows(r, ['method', 'path', 'controller', 'action'])