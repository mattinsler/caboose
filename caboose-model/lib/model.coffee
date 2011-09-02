Query = require './query'
Collection = require './collection'

class Model
  @_ensure_collection: (callback) ->
    callback() if @_collection
    Collection.create @_collection_name, (err, collection) ->
      return console.error err.stack if err?
      @_collection = collection
      callback @_collection
  
  @first: (callback) ->
    new Query(this).first callback
  
  @where: (query) ->
    new Query this, query

  @save: (doc, callback) ->
    @_ensure_collection (c) =>
      execute = ->
        c.save doc, (err) ->
          return callback and callback err if err?
          callback and callback null, doc

      index = 0
      next = =>
        return execute() if index is @_before_save.length
        @_before_save[index++] doc, next
      next()

  @update: (query, update, callback) ->
    @_ensure_collection (c) ->
      c.update query, update, (err) =>
        callback and callback err

module.exports = Model