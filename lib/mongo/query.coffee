Spec = require './spec'

module.exports = class Query
  constructor: (@collection, @spec, @query) ->
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
    query = @spec.filter @query, Spec.nameToKey
    @collection.find(query, @options).each (err, item) =>
      return callback err if err?
      callback null, @spec.wrap item
  array: (callback) ->
    query = @spec.filter @query, Spec.nameToKey
    @collection.find(query, @options).toArray (err, items) =>
      return callback err if err?
      callback null, (@spec.wrap i for i in items)
    
class One extends Query
  constructor: (collection, spec, query) ->
    super collection, spec, query

  exec: (callback) ->
    query = @spec.filter @query, Spec.nameToKey
    @collection.findOne query, (err, item) =>
      return callback err if err?
      callback null, @spec.wrap item
      
Query.One = One