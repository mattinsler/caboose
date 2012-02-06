exports.description = 'Open a console with the environment loaded'

exports.method = ->
  repl = require 'repl'
  context = repl.start().context
  for m in Caboose.app.models
    context[m._name] = m
