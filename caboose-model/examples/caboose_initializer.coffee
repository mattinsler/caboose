Model = require 'caboose-model'

module.exports = (next) ->
  Model.configure {
    host: 'localhost'
    port: 27017
    database: 'test'
  }
  Model.add_plugin 'caboose-authentication'
  
  Caboose.registry.register {
    get: (parsed_name) ->
      try
        return Caboose.path.models.join(parsed_name.join('_')).require()
      catch e
        console.error e.stack
      null
  }
  next()
