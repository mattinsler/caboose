return module.exports = global['caboose-model'] if global['caboose-model']?

logger = Caboose.logger

module.exports = global['caboose-model'] = caboose_model =
  connection: null

  create: (name) -> new caboose_model.Builder(name)
  configure: (config) ->
    @config = config
    # Test the connection
    # caboose_model.Collection.create 'test', (err) ->
    #   if err?
    #     if err.code is 'ECONNREFUSED'
    #       logger.error 'Could not connect to MongoDB database'
    #     else
    #       logger.error err.stack
    #     process.exit(1)
    @
  
  # This is to be used to ensure a connection is made
  # Potentially the connection will not work and connect
  # could be called multiple times until it works
  connect: (callback) ->
    return callback(null, caboose_model.connection) if caboose_model.connection?
    return callback(new Error('No configuration found for caboose-model')) unless caboose_model.config?
    
    conn = new caboose_model.Connection()
    conn.open caboose_model.config, (err, c) ->
      return callback(err) if err?
      caboose_model.connection = c
      callback(null, c)    
  
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
