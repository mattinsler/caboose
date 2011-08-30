mongodb = require 'mongodb'
Model = require './model'

module.exports = class Connection
  open: (conn_string, callback) ->
    return callback null, @db if @db?
    
    uri = require('url').parse conn_string
    host = uri.hostname
    port = uri.port ? 27017
    dbName = uri.pathname.replace /\//g, ''
    if uri.auth?
      [user, password] = uri.auth.split ':'
    
    if not @db
      try
        @db = new mongodb.Db dbName, new mongodb.Server(host, port), native_parser: true
      catch e
        @db = new mongodb.Db dbName, new mongodb.Server(host, port)
      
    @db.open (err, db) =>
      console.error err.stack if err?
      # @registerModel m for m in @models if not err?
      if user? and password?
        @db.authenticate user, password, =>
          callback? err, @db
      else
        callback? err, @db
  close: ->
    if @db?
      @db.close()
      delete @db

  model: (name) ->
    m = new Model()
    @db.collection name, (err, c) ->
      m.collection = c
    return m
