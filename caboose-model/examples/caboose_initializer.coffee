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
      name = parsed_name.join('_')
      try
        files = Caboose.path.models.readdir_sync()
        model_file = _(files).find((f) -> f.basename is name)
        return null unless model_file?
        return model_file if model_file.extension is 'coffee'
        model_file.requre()
      catch e
        console.error e.stack
      null
  }
  next()
