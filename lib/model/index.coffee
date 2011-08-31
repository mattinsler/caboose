Builder = require './builder'
Connection = require './connection'

exports.connections = {}

exports.connect = (conn_string, callback) ->
  conn = exports.connections[conn_string]
  if not conn?
    conn = exports.connections[conn_string] = new Connection()
  conn.open conn_string, callback

exports.model = (name) ->
  exports.connections[Object.keys(exports.connections)[0]].model name

exports.builder = (name) ->
  new Builder name