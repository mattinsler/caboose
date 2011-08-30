Query = require './query'

module.exports = class Model
  constructor: (@collection) ->
  
  first: (callback) ->
    new Query(@collection).first callback
  
  where: (query) ->
    new Query @collection, query

  save: (doc, callback) ->
    @collection.save doc, (err) ->
      console.log 'saved'
      console.log doc
      return callback and callback err if err?
      callback and callback null, doc

  update: (query, update, callback) ->
    @collection.update query, update, (err) =>
      callback and callback err
