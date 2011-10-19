path = require 'path'
require 'coffee-script'

exports.description = 'Run a script'

exports.method = (script) ->
  throw new Error 'caboose run requires a script argument' if not script?
  Caboose.app.initialize ->
    require path.join(process.cwd(), script)
