mongodb = require 'mongodb'

class Mongo
  constructor: ->
    @models = []

  connect: (connectionString, callback) ->
    uri = require('url').parse connectionString
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
      @registerModel m for m in @models if not err?
      if user? and password?
        @db.authenticate user, pass, =>
          callback? err, @db
      else
        callback? err, @db
  close: ->
    @db.close()
    
  registerModel: (model) ->
    @models.push model
    if @db?
      @db.collection model.collection_name, (err, c) ->
        return console.error err.stack if err?
        model.collection = c

module.exports = new Mongo()