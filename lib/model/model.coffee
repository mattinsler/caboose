path = require 'path'
mongodb = require 'mongodb'
Spec = require './spec'
Query = require './query'
Mongo = require './mongo'

class Model
  constructor: (@name, @collection_name, @spec) ->
    Mongo.registerModel this

    # create dynamic finders
    for index in @spec.indexes
      this['by_' + index.fields[0].name] = (value) =>
        query = {}
        query[index.fields[0].name] = value
        new Query @collection, @spec, query

    this[k] = v for k, v of @spec.statics

  count: (callback) ->
    @collection.count callback

  where: (query) ->
    new Query @collection, @spec, query
    
  save: (doc, callback) ->
    err = @spec.validate doc
    return callback and callback err if err?
    fixed = @spec.filter doc, Spec.ApplyDefault, Spec.ApplySetter, Spec.NameToKey
    @collection.save fixed, (err) =>
      return callback and callback err if err?
      callback and callback null, @spec.filter fixed, Spec.KeyToName
  
  update: (query, update, callback) ->
    fixedQuery = @spec.filter query, Spec.NameToKey
    # fixedUpdate = @spec.filter update, Spec.NameToKey
    console.log 'update'
    console.log fixedQuery
    console.log update
    @collection.update fixedQuery, update, (err) =>
      callback and callback err
    
  @Timestamp: mongodb.BSONNative.Timestamp

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