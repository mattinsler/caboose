path = require 'path'
Application = require './lib/application'

if not global.Caboose?
  global.Caboose = {
    root: process.cwd()
    env: process.env.caboose_env ? 'development'
  }
  global.Caboose.path = {
    app: path.join global.Caboose.root, 'app'
    config: path.join global.Caboose.root, 'config'
    plugins: path.join global.Caboose.root, 'plugins'
    public: path.join global.Caboose.root, 'public'
    test: path.join global.Caboose.root, 'test'
    temp: path.join global.Caboose.root, 'tmp'
  }
  global.Caboose.path.controllers = path.join global.Caboose.path.app, 'controllers'
  global.Caboose.path.models = path.join global.Caboose.path.app, 'models'
  global.Caboose.path.helpers = path.join global.Caboose.path.app, 'helpers'
  global.Caboose.path.views = path.join global.Caboose.path.app, 'views'

  global.Caboose.registry = require './lib/registry'
  global.Caboose.app = new Application()

exports.cli = require './lib/cli'
exports.model = require './lib/model'
exports.registry = global.Caboose.registry





# 
# exports.Model = require './lib/model/model'

# exports.test = (run_path, options) ->
#   vows = require 'vows'
#   create_and_initialize_app options, (app) ->
#     if options._.length > 0
#       require path.join(app.paths.test, name) for name in options._
#       vows.suites[0].run {}, -> process.exit()
# 
# exports.run = (run_path, options) ->
#   return console.log 'USAGE: caboose run script_filename' if options._.length isnt 1
#   return console.log "ERROR: Could not find file #{options._[0]}" unless path.existsSync options._[0]
#   create_and_initialize_app options, (app) ->
#     require options._[0]
