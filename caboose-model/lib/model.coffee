mongodb = require 'mongodb'
Query = require './query'
Collection = require './collection'

class Model
  constructor: (doc) ->
    this[k] = v for k, v of doc
  
  save: (callback) ->
    @__type__.save this, callback
  
  update: (query, update, callback) ->
    return callback new Error 'Models must have an _id field in order to call update' unless @_id?
    if !update? or typeof update is 'function' # no query
      callback = arguments[1]
      update = arguments[0]
      query = {_id: @_id}
    else
      query._id = @_id
    @__type__.update query, update, callback
  
  remove: (callback) ->
    return callback(new Error('Models must have an _id field in order to call remove')) unless @_id?
    @__type__.remove {_id: @_id}, callback
  
  @__ensure_collection__: (callback) ->
    return callback(@__collection__) if @__collection__?
    Collection.create @__collection_name__, (err, collection) =>
      return console.error(err.stack) if err?
      Object.defineProperty(@, '__collection__', {value: collection, enumerable: false}) unless @__collection__
      callback @__collection__
  
  @first: (callback) ->
    new Query(this).first callback
  
  @array: (callback) ->
    new Query(this).array callback
  
  @each: (callback) ->
    new Query(this).each callback
  
  @count: (callback) ->
    new Query(this).count callback
    
  @distinct: (key, callback) ->
    new Query(this).distinct key, callback

  @skip: (count) ->
    new Query(this).skip(count)
  
  @limit: (count) ->
    new Query(this).limit(count)

  @sort: (fields) ->
    new Query(this).sort(fields)
  
  @fields: (fields) ->
    new Query(this).fields(fields)

  @where: (query) ->
    new Query(this, query)

  @save: (doc, callback) ->
    @__ensure_collection__ (c) =>
      execute = ->
        if callback?
          c.save doc, {safe: true}, (err) ->
            callback(err, doc)
        else
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
    @__ensure_collection__ (c) ->
      c.update query, update, options, callback

  @update_multi: (query, update, callback) ->
    @update query, update, {multi: true}, callback
  
  @upsert: (query, update, callback) ->
    @update query, update, {upsert: true}, callback
  
  @remove: (query, callback) ->
    @__ensure_collection__ (c) ->
      return c.remove(query, {safe: true}, callback) if callback?
      c.remove query
  
  @find_and_modify: (options, callback) ->
    opts = {}
    for k in ['remove', 'new', 'upsert']
      opts[k] = options[k] if options[k]
    # collection.findAndModify(query, sort, update, options, callback)
    @__ensure_collection__ (c) =>
      c.findAndModify options.query, options.sort || [], options.update, opts, callback
  
  @map_reduce: (map, reduce, options, callback) ->
    @__ensure_collection__ (c) =>
      c.mapReduce map, reduce, options, (err, collection) ->
        return callback(err) if err?
        
        model = class extends Model
        model.__type__ = model
        model.__collection__ = collection
        callback(null, model)

Object.defineProperty(Model, '__ensure_collection__', {enumerable: false})

field_names = ['Long', 'ObjectID', 'Timestamp', 'DBRef', 'Binary', 'Code']
try
  new mongodb.Db 'test', new mongodb.Server('localhost', 27017), native_parser: true
  bson = 'BSONNative'
catch e
  new mongodb.Db 'test', new mongodb.Server('localhost', 27017)
  bson = 'BSONPure'

for fn in field_names
  Object.defineProperty(Model, fn, {value: mongodb[bson][fn], enumerable: false})
  Object.defineProperty(Query, fn, {value: mongodb[bson][fn], enumerable: false})

module.exports = Model
