require 'colors'

exports.description = 'Open a console with the environment loaded'

load_models = (callback) ->
  return callback([]) unless Caboose.path.models.exists_sync()
  console.log 'Loading Models'.blue

  models = []
  for file in Caboose.path.models.readdir_sync()
    if file.extension in ['js', 'coffee']
      model = Caboose.registry.get file.basename
      console.log "        #{model._name}".green
      models.push model
  
  callback models

exports.method = ->
  Caboose.app.initialize ->
    load_models (models) ->
      repl = require 'repl'
      context = repl.start().context
      for m in models
        context[m._name] = m
