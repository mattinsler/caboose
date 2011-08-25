exports.description = 'Open a console with the environment loaded'

exports.method = ->
  Caboose.app.initialize ->
    repl = require 'repl'
    repl.start()