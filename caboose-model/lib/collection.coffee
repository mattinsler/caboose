caboose_model = require '../index'
Connection = require './connection'

module.exports = class Collection
  @create: (collection_name, callback) ->
    return caboose_model.connection.collection collection_name, callback if caboose_model.connection?
    conn = new Connection()
    conn.open caboose_model.config, (err, c) ->
      return console.error err.stack if err?
      caboose_model.connection = c
      caboose_model.connection.collection collection_name, callback