caboose_model = require '../index'
Connection = require './connection'

module.exports = class Collection
  @create: (connection_name, collection_name, callback) ->
    return caboose_model.connections[connection_name].collection(collection_name, callback) if caboose_model.connections[connection_name]?
    return callback(new Error('No configuration found for caboose-model')) unless caboose_model.configs?
    return callback(new Error("No configuration found for #{connection_name} connection")) unless caboose_model.configs[connection_name]?
    conn = new Connection()
    conn.open caboose_model.configs[connection_name], (err, c) ->
      return callback(err) if err?
      caboose_model.connections[connection_name] = c
      caboose_model.connections[connection_name].collection collection_name, callback
