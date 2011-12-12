path = require 'path'
Model = require 'caboose-model'

module.exports = (next) ->
  Model.configure Caboose.app.config.model
  
  Caboose.registry.register {
    get: (parsed_name) ->
      try
        return Caboose.path.models.join(parsed_name.join('_')).require()
      catch e
        console.error e.stack
      null
  }
  next()
