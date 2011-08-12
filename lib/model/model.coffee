path = require 'path'
mongodb = require 'mongodb'
Spec = require './spec'
Query = require './query'
Mongo = require './mongo'
Type = require './type'

class Model
  constructor: (@name, @collection_name, @spec) ->
    Mongo.registerModel this

    # create dynamic finders
    create_finder = (index) =>
      @['by_' + index.fields[0].name] = (value) =>
        query = {}
        query[index.fields[0].name] = value
        new Query @collection, @spec, query
    create_finder index for index in @spec.indexes

    @[k] = v for k, v of @spec.statics

  count: (callback) ->
    @collection.count callback

  where: (query) ->
    new Query @collection, @spec, query
    
  save: (doc, callback) ->
    err = @spec.validate doc
    return callback and callback err if err?
    fixed = @spec.to_plain doc
    @collection.save fixed, (err) =>
      return callback and callback err if err?
      callback and callback null, @spec.from_server fixed
  
  update: (query, update, callback) ->
    # fixedQuery = @spec.filter query, Spec.NameToKey
    fixedQuery = @spec.to_query query
    # fixedUpdate = @spec.filter update, Spec.NameToKey
    fixedUpdate = @spec.to_query update
    console.log 'update'
    console.log fixedQuery
    console.log fixedUpdate
    @collection.update fixedQuery, fixedUpdate, (err) =>
      callback and callback err
    
  @Timestamp: mongodb.BSONNative?.Timestamp ? mongodb.BSONPure.Timestamp

  @connect: -> Mongo.connect.apply Mongo, arguments
  
  @compile = (filename) ->
    return null if not path.existsSync filename
    ModelCompiler = require './model_compiler'
    compiler = new ModelCompiler()
    # compiler.debug = true
    try
      compiler.compile_file filename
    catch err
      console.log "Error trying to compile Model for #{filename}"
      console.error err.stack
      null

module.exports = Model
module.exports.Type = Type
module.exports.Spec = Spec