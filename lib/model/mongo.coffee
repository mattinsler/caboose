mongodb = require 'mongodb'

class Mongo
  constructor: ->
    @models = []

  connect: (connectionString, callback) ->
    parse = (cs) ->
      parts = /^mongodb:\/\/([^:/]+)(:([0-9]+))?(\/(.+))?$/.exec cs
      return null if not parts?
      [
        parts[1],
        (parseInt parts[3] if parts[3]?) ? 27017,
        parts[5] ? ''
      ]
    [host, port, dbName] = parse connectionString
    
    if not @db
      try
        @db = new mongodb.Db dbName, new mongodb.Server(host, port), native_parser: true
      catch e
        @db = new mongodb.Db dbName, new mongodb.Server(host, port)
      
    @db.open (err, db) =>
      console.error err.stack if err?
      @registerModel m for m in @models if not err?
      callback? err, db
  close: ->
    @db.close()
    
  registerModel: (model) ->
    @models.push model
    if @db?
      @db.collection model.collection_name, (err, c) ->
        return console.error err.stack if err?
        model.collection = c

module.exports = new Mongo()