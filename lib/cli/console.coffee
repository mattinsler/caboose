exports.description = 'Open a console with the environment loaded'

exports.method = ->
  repl = require 'repl'
  context = repl.start().context
  context.$_ = -> console.log(arguments)
  if Caboose.app?.models?
    for m in Caboose.app.models
      name = if m.__name__? then m.__name__ else /function ([^\(]+)/.exec(m.toString())[1]
      context[name] = m
