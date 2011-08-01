Spec = require './spec'

module.exports = class Query
  constructor: (@collection, @spec, @query) ->
    @query ?= {}
    @options = {}

  skip: (count) ->
    @options.skip = count
    this

  limit: (count) ->
    @options.limit = count
    this

  sort: () ->
    this

  each: (callback) ->
    query = @spec.filter @query, Spec.NameToKey
    @collection.find(query, @options).each (err, item) =>
      return callback err if err?
      callback null, @spec.wrap item

  array: (callback) ->
    query = @spec.filter @query, Spec.NameToKey
    @collection.find(query, @options).toArray (err, items) =>
      return callback err if err?
      callback null, (@spec.wrap i for i in items)

  first: (callback) ->
    query = @spec.filter @query, Spec.NameToKey
    @options.limit = 1
    @collection.find(query, @options).nextObject (err, item) =>
      return callback err if err?
      callback null, @spec.wrap item
  
  count: (callback) ->
    query = @spec.filter @query, Spec.NameToKey
    @collection.count query, callback