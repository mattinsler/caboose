return module.exports = global['caboose-model'] if global['caboose-model']?

_ = require 'underscore'
async = require 'async'
logger = Caboose.logger

module.exports = global['caboose-model'] = caboose_model =
  connections: {}

  create: (name) -> new caboose_model.Builder(name)
  configure: (config) ->
    @configs = {}
    if config.database? or config.url?
      @configs.default = config
    else
      for k, v of config
        @configs[k] = v
    @
  
  # This is to be used to ensure a connection is made
  # Potentially the connection will not work and connect
  # could be called multiple times until it works
  connect: (callback) ->
    return callback(new Error('No configuration found for caboose-model')) unless caboose_model.configs?
    
    a = _(caboose_model.configs).inject (o, v, k) ->
      o[k] = (cb) ->
        return cb(null, caboose_model.connections[k]) if caboose_model.connections[k]?
        return cb(new Error("No configuration found for #{k} connection")) unless caboose_model.configs[k]?
        conn = new caboose_model.Connection()
        conn.open caboose_model.configs[k], (err, c) ->
          return callback(err) if err?
          caboose_model.connections[k] = c
          cb(null, c)
    , {}
    
    async.parallel(a, callback)
  
  'caboose-plugin': {
    install: (util, logger) ->
      util.mkdir(Caboose.path.app.join('models'))
      util.create_file(
        Caboose.path.config.join('caboose-model.json'),
        JSON.stringify({host: 'localhost', port: 27017, database: Caboose.app.name}, null, 2)
      )

    initialize: ->
      if Caboose?
        Caboose.path.models = Caboose.path.app.join('models')
        
        # load models
        Caboose.app.after 'initialize', (app) ->
          app.models = []
          if Caboose.path.models.exists_sync()
            for file in Caboose.path.models.readdir_sync()
              app.models.push(Caboose.registry.get(file.basename)) if file.extension in ['js', 'coffee']

        require './lib/cli'
        
        Caboose.registry.register 'model', {
          get: (parsed_name) ->
            return null unless Caboose.path.models.exists_sync()
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

caboose_model.Builder = require './lib/builder'
caboose_model.Compiler = require './lib/model_compiler'
caboose_model.Connection = require './lib/connection'
caboose_model.Collection = require './lib/collection'
caboose_model.Model = require './lib/model'
caboose_model.Query = require './lib/query'
caboose_model.Promise = Caboose.exports.promise
caboose_model.mongodb = require 'mongodb'
