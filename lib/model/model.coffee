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

  count: (callback) ->
    @collection.count callback

  where: (query) ->
    new Query @collection, @spec, query
    
  save: (doc, callback) ->
    err = @spec.validate doc
    return callback err if err?
    fixed = @spec.filter doc, Spec.applyDefault, Spec.nameToKey
    @collection.save fixed, (err) =>
      return callback && callback err if err?
      callback && callback null, @spec.filter fixed, Spec.keyToName
  
  update: (query, update, callback) ->
    fixedQuery = @spec.filter query, Spec.nameToKey
    fixedUpdate = @spec.filter update, Spec.nameToKey
    @collection.update fixedQuery, fixedUpdate, callback

Model.Timestamp = mongodb.BSONNative.Timestamp
Model.connect = -> Mongo.connect.apply Mongo, arguments
Model.compile = (filename) ->
  ModelCompiler = require './model_compiler'
  compiler = new ModelCompiler()
  compiler.compile_file filename

module.exports = Model