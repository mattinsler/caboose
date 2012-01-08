exports.description = 'Open a console with the environment loaded'

exports.method = ->
  models = Caboose.app.load_models()
  repl = require 'repl'
  context = repl.start().context
  for m in models
    context[m._name] = m
