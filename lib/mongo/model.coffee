mongodb = require 'mongodb'
Spec = require './spec'
Query = require './query'
Mongo = require './mongo'

module.exports = class Model
  constructor: (@name, config) ->
    @spec = Spec.create config
    Mongo.registerModel this

    # create dynamic finders
    for index in @spec.indexes
      this['one_by_' + index.fields[0].name] = (value) =>
        query = {}
        query[index.fields[0].name] = value
        new Query.One @collection, @spec, query
      this['all_by_' + index.fields[0].name] = (value) =>
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
      if err? then callback err else callback null, @spec.filter fixed, Spec.keyToName
  
  update: (query, update, callback) ->
    fixedQuery = @spec.filter query, Spec.nameToKey
    fixedUpdate = @spec.filter update, Spec.nameToKey
    @collection.update fixedQuery, fixedUpdate, callback

module.exports.Timestamp = mongodb.BSONNative.Timestamp