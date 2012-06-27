_ = require 'underscore'

module.exports = class Query
  constructor: (@model, @query) ->
    @query = @model.__fix_query__(@query ? {})
    @options = {}

  __error__: (promise, err) ->
    promise.error(err)

  __complete__: (promise, value) ->
    promise.complete(value)
  
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
    promise = new @model.__Promise__(callback)
    @command = 'first'

    @model.__ensure_collection__ (c) =>
      @options.limit = 1
      c.find(@query, @options).nextObject (err, item) =>
        return @__error__(promise, err) if err?
        @__complete__(promise, if item? then new @model(item) else null)

    promise

  array: (callback) ->
    promise = new @model.__Promise__(callback)
    @command = 'array'
    
    @model.__ensure_collection__ (c) =>
      c.find(@query, @options).toArray (err, items) =>
        return @__error__(promise, err) if err?
        if items?
          items[x] = new @model(items[x]) for x in [0...items.length]
        @__complete__(promise, items)
    
    promise

  each: (callback) ->
    @model.__ensure_collection__ (c) =>
      c.find(@query, @options).each (err, item) =>
        return callback(err) if err?
        callback(null, if item? then new @model(item) else null)
  
  count: (callback) ->
    promise = new @model.__Promise__(callback)
    @command = 'count'
    
    @model.__ensure_collection__ (c) =>
      c.count @query, (err, count) =>
        return @__error__(promise, err) if err?
        @__complete__(promise, count)
    
    promise

  distinct: (key, callback) ->
    promise = new @model.__Promise__(callback)
    @command = 'distinct'
    
    @model.__ensure_collection__ (c) =>
      c.distinct key, @query, (err, keys) =>
        return @__error__(promise, err) if err?
        @__complete__(promise, keys)
    
    promise
