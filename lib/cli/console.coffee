fs = require 'fs'
path = require 'path'
colors = require 'colors'

exports.description = 'Open a console with the environment loaded'

load_models = (callback) ->
  console.log '------------------------------'.grey
  console.log '| '.grey + 'Loading Models'.blue
  console.log '------------------------------'.grey

  models = []
  for file in Caboose.path.models.readdir_sync()
    match = /^(.+)\.(js|coffee)$/.exec(file)
    if match?
      model = Caboose.registry.get match[1]
      console.log '| '.grey + 'Loaded: '.blue + model._name.green
      models.push model
  
  console.log '------------------------------'.grey
  callback models

exports.method = ->
  Caboose.app.initialize ->
    load_models (models) ->
      repl = require 'repl'
      context = repl.start().context
      for m in models
        context[m._name] = m
