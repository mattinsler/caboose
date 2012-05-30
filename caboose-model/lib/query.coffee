_ = require 'underscore'
Promise = Caboose.exports.promise

module.exports = class Query
  constructor: (@model, @query) ->
    @query ?= {}
    @query._id = new Query.ObjectID(@query._id) if @query._id? and typeof @query._id is 'string' and /[0-9a-z]{24}/i.test(@query._id)
    @options = {}
  
  where: (query) ->
    _.extend(@query, query)
    @

  skip: (count) ->
    @options.skip = count
    @

  limit: (count) ->
    @options.limit = count
    @

  sort: (fields) ->
    @options.sort = fields
    @
  
  fields: (fields) ->
    @options.fields = fields
    @

  first: (callback) ->
    promise = new Promise(callback)

    @model.__ensure_collection__ (c) =>
      @options.limit = 1
      c.find(@query, @options).nextObject (err, item) =>
        return promise.error(err) if err?
        promise.complete(if item? then new @model(item) else null)

    promise

  array: (callback) ->
    promise = new Promise(callback)
    
    @model.__ensure_collection__ (c) =>
      c.find(@query, @options).toArray (err, items) =>
        return promise.error(err) if err?
        if items?
          items[x] = new @model(items[x]) for x in [0...items.length]
        promise.complete(items)
    
    promise

  each: (callback) ->
    @model.__ensure_collection__ (c) =>
      c.find(@query, @options).each (err, item) =>
        return callback(err) if err?
        callback null, (if item? then new @model(item) else null)
  
  count: (callback) ->
    promise = new Promise(callback)
    
    @model.__ensure_collection__ (c) =>
      c.count @query, promise.callback.bind(promise)
    
    promise

  distinct: (key, callback) ->
    promise = new Promise(callback)
    
    @model.__ensure_collection__ (c) =>
      c.distinct key, @query, promise.callback.bind(promise)
    
    promise
