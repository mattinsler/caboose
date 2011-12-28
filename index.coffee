Path = require './lib/path'
Application = require './lib/application'

if not global.Caboose?
  Caboose = global.Caboose = {
    root: new Path()
    env: process.env.CABOOSE_ENV ? 'development'
  }
  Caboose.path = {
    app: Caboose.root.join('app')
    config: Caboose.root.join('config')
    lib: Caboose.root.join('lib')
    plugins: Caboose.root.join('plugins')
    public: Caboose.root.join('public')
    test: Caboose.root.join('test')
    tmp: Caboose.root.join('tmp')
  }
  Caboose.path.controllers = Caboose.path.app.join('controllers')
  Caboose.path.models = Caboose.path.app.join('models')
  Caboose.path.helpers = Caboose.path.app.join('helpers')
  Caboose.path.views = Caboose.path.app.join('views')

  Caboose.registry = require './lib/registry'
  Caboose.app = new Application()

exports.cli = require './lib/cli'
exports.registry = global.Caboose.registry
exports.path = Path

exports.internal = {
  compiler: require './lib/compiler'
}


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
