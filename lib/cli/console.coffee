_ = {str: require 'underscore.string'}

exports.description = 'Open a console with the environment loaded'

exports.method = ->
  repl = require 'repl'
  if Caboose.versions.node.minor is 6
    context = repl.start().context
  else if Caboose.versions.node.minor in [8, 10]
    context = repl.start({
      prompt: "caboose:#{Caboose.app.name}> "
      useColors: true
    }).context
  
  context.$_ = -> console.log(arguments)
  if Caboose.app?.models?
    for m in Caboose.app.models
      name = m.__name__
      unless name?
        parsed = /function ([^\(]+)/.exec(m.toString())
        name = parsed[1] if parsed?
      context[name] = m
  
  for file in Caboose.path.controllers.readdir_sync()
    try
      obj = Caboose.get(file.basename)
      context[obj._name] = obj
    catch e
