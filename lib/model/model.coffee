Query = require './query'

class Model
  @first: (callback) ->
    new Query(@_collection).first callback
  
  @where: (query) ->
    new Query @_collection, query

  @save: (doc, callback) ->
    @_collection.save doc, (err) ->
      console.log 'saved'
      console.log doc
      return callback and callback err if err?
      callback and callback null, doc

  @update: (query, update, callback) ->
    @_collection.update query, update, (err) =>
      callback and callback err

module.exports = Model