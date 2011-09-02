mongodb = require 'mongodb'
Model = require './model'

module.exports = class Connection
  _parse_options: (conn_string) ->
    uri = require('url').parse conn_string
    options = {
      host: uri.hostname
      port: uri.port ? 27017
      database: uri.pathname.replace /\//g, ''
    }
    if uri.auth?
      [options.user, options.password] = uri.auth.split ':'
    options
  
  open: (conn_string, callback) ->
    return callback null, @db if @db?
    
    if typeof conn_string is 'string'
      options = @_parse_options conn_string
    else
      options = conn_string
    
    if not @db
      try
        @db = new mongodb.Db options.database, new mongodb.Server(options.host, options.port), native_parser: true
      catch e
        @db = new mongodb.Db options.database, new mongodb.Server(options.host, options.port)
      
    @db.open (err, db) =>
      console.error err.stack if err?
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
