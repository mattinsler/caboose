return module.exports = global['caboose-model'] if global['caboose-model']?

caboose_model =
  version: [0, 1, 1]

  Builder: require './lib/builder'
  Compiler: require './lib/model_compiler'
  Connection: require './lib/connection'
  Model: require './lib/model'
  Query: require './lib/query'

  connection: null

  create: (name) -> new caboose_model.Builder(name)
  configure: (config) ->
    caboose_model.config = config
    this

caboose_model['caboose-plugin'] = {
  cli: require './lib/cli'
  initialize: ->
    if Caboose?
      Caboose.registry.register 'model', {
        get: (parsed_name) ->
          name = parsed_name.join('_')
          try
            files = Caboose.path.models.readdir_sync()
            model_file = files.filter((f) -> f.basename is name)
            model_file = if model_file.length > 0 then model_file[0] else null
            return null unless model_file?
            return caboose_model.Compiler.compile(model_file) if model_file.extension is 'coffee'
            model_file.require()
          catch e
            console.error e.stack
      }

    if Caboose?.app?.config?['caboose-model']?
      caboose_model.configure Caboose.app.config['caboose-model']
}

global['caboose-model'] = module.exports = caboose_model
