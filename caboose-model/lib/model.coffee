mongodb = require 'mongodb'
Query = require './query'
Collection = require './collection'

class Model
  constructor: (doc) ->
    this[k] = v for k, v of doc
  
  save: (callback) ->
    @_type.save this, callback
  
  update: (update, callback) ->
    return callback new Error 'Models must have an _id field in order to call update' unless @_id?
    @_type.update {_id: @_id}, update, callback
  
  remove: (callback) ->
    return callback new Error 'Models must have an _id field in order to call remove' unless @_id?
    @_type.remove {_id: @_id}, callback
  
  @_ensure_collection: (callback) ->
    callback() if @_collection
    Collection.create @_collection_name, (err, collection) ->
      return console.error err.stack if err?
      @_collection = collection
      callback @_collection
  
  @first: (callback) ->
    new Query(this).first callback
  
  @count: (callback) ->
    new Query(this).count callback
  
  @where: (query) ->
    new Query this, query

  @save: (doc, callback) ->
    @_ensure_collection (c) =>
      execute = ->
        return c.save(doc, {safe: true}, callback) if callback?
        c.save doc

      index = 0
      next = (err) =>
        return callback(err) if err?
        return execute() if index is @_before_save.length
        @_before_save[index++] doc, next
      next()

  @update: (query, update, options, callback) ->
    callback = options if options? and typeof options is 'function'
    options or= {}
    options.safe = true if callback?
    @_ensure_collection (c) ->
      c.update query, update, options, callback

  @update_multi: (query, update, callback) ->
    @update query, update, {multi: true}, callback
  
  @upsert: (query, update, callback) ->
    @update query, update, {upsert: true}, callback
  
  @remove: (query, callback) ->
    @_ensure_collection (c) ->
      return c.remove(query, {safe: true}, callback) if callback?
      c.remove query
  
  @distinct: (key, callback) ->
    new Query(this).distinct key, callback
  
  @find_and_modify: (options, callback) ->
    opts = {}
    for k in ['remove', 'new', 'upsert']
      opts[k] = options[k] if options[k]
    # collection.findAndModify(query, sort, update, options, callback)
    @_ensure_collection (c) =>
      c.findAndModify options.query, options.sort || [], options.update, opts, callback

field_names = ['Long', 'ObjectID', 'Timestamp', 'DBRef', 'Binary', 'Code']
try
  new mongodb.Db 'test', new mongodb.Server('localhost', 27017), native_parser: true
  bson = 'BSONNative'
catch e
  new mongodb.Db 'test', new mongodb.Server('localhost', 27017)
  bson = 'BSONPure'

for fn in field_names
  Model[fn] = mongodb[bson][fn]

module.exports = Model
