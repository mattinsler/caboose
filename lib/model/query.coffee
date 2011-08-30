module.exports = class Query
  constructor: (@collection, @query) ->
    @query ?= {}
    @options = {}

  skip: (count) ->
    @options.skip = count
    this

  limit: (count) ->
    @options.limit = count
    this

  sort: (fields) ->
    @options.sort = fields
    this

  each: (callback) ->
    @collection.find(@query, @options).each (err, item) =>
      return callback err if err?
      callback null, item

  array: (callback) ->
    @collection.find(@query, @options).toArray (err, items) =>
      return callback err if err?
      callback null, items

  first: (callback) ->
    @options.limit = 1
    @collection.find(@query, @options).nextObject (err, item) ->
      return callback err if err?
      callback null, item
  
  count: (callback) ->
    @collection.count @query, callback
