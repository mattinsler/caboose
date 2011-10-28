path = require 'path'
require 'coffee-script'

exports.description = 'Run a script'

load_models = (callback) ->
  for file in Caboose.path.models.readdir_sync()
    match = /^(.+)\.(js|coffee)$/.exec(file)
    Caboose.registry.get(match[1]) if match?
  callback()

exports.method = (script) ->
  throw new Error 'caboose run requires a script argument' if not script?
  Caboose.app.initialize ->
    load_models ->
      if script.indexOf('/') is 0
        require script
      else
        require path.join(process.cwd(), script)
