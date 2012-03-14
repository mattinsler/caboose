exports.description = 'Open a console with the environment loaded'

exports.method = ->
  repl = require 'repl'
  context = repl.start().context
  if Caboose.app?.models?
    context[m._name] = m for m in Caboose.app.models
