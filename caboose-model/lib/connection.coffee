util = require 'util'
mongodb = require 'mongodb'
Model = require './model'
caboose_model = require '../index'

module.exports = class Connection
  _parse_options: (conn_string) ->
    uri = require('url').parse conn_string
    options = {
      host: uri.hostname
      port: parseInt(uri.port) ? 27017
      database: uri.pathname.replace /\//g, ''
    }
    if uri.auth?
      [options.user, options.password] = uri.auth.split ':'
    options
  
  open: (options, callback) ->
    return callback null, @db if @db?
    
    options = @_parse_options(options.url) if options.url?
    
    if not @db
      try
        @db = new mongodb.Db options.database, new mongodb.Server(options.host, options.port), native_parser: true
      catch e
        @db = new mongodb.Db options.database, new mongodb.Server(options.host, options.port)
      
    @db.open (err, db) =>
      # console.error(if err.stack? then err.stack else util.inspect(err, true, 5)) if err?
      return callback?(err) if err?
      # @registerModel m for m in @models if not err?
      if options.user? and options.password?
        @db.authenticate options.user, options.password, =>
          callback? err, @db
      else
        callback? err, @db
  close: ->
    if @db?
      @db.close()
      delete @db

  collection: (name, callback) ->
    @db.collection name, callback

  @create: (connection_name = 'default', callback) ->
    if typeof connection_name is 'function'
      callback = connection_name
      connection_name = 'default'
    
    done = ->
      caboose_model.emit('connected', connection_name, caboose_model.connections[connection_name])
      callback(null, caboose_model.connections[connection_name])
    
    # already have connection, so return it
    return done() if caboose_model.connections[connection_name]?
    
    return callback(new Error('No configuration found for caboose-model')) unless caboose_model.configs?
    return callback(new Error("No configuration found for #{connection_name} connection")) unless caboose_model.configs[connection_name]?
    
    # if connection is pending, listen for the connection and return it
    if caboose_model.connections_pending[connection_name]?
      listener = (name, conn) ->
        if name is connection_name
          caboose_model.removeListener('connected', listener)
          done()
      return caboose_model.on('connected', listener)
    
    caboose_model.connections_pending[connection_name] = true
    
    conn = new Connection()
    conn.open caboose_model.configs[connection_name], (err, c) ->
      if err?
        callback(err)
      else
        caboose_model.connections[connection_name] = c
        done()
      delete caboose_model.connections_pending[connection_name]
