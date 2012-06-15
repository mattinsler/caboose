caboose_model = require '../index'
Connection = require './connection'

module.exports = class Collection
  @create: (connection_name, collection_name, callback) ->
    Connection.create connection_name, (err, conn) ->
      return callback(err) if err?
      conn.collection(collection_name, callback)
