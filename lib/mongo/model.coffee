mongodb = require 'mongodb'
Spec = require './spec'
Mongo = require './mongo'

module.exports = class Model
  constructor: (@name, config) ->
    @spec = new Spec()
    config.call @spec
    Mongo.registerModel this
  
  _wrap: (item) ->
    class Wrapper
      constructor: (doc) ->
        Object.defineProperty this, 'doc', value: doc
    wrapped = new Wrapper item
    for field in @spec.fields
      do (field) ->
        Object.defineProperty wrapped, field.name, {
          enumerable: true,
          get: ->
            value = field.get @doc[field.key]
            # field.validate? value
            value
        }
    wrapped
    
  count: (callback) ->
    @collection.count callback

  find: (id, callback) ->
    @collection.findOne {_id: id}, (err, item) =>
      return callback err if err?
      callback null, @_wrap item
    
  where: (query) ->
    
  save: (doc, callback) ->
    try
      for field in @spec.fields
        do (field) ->
          field.validator doc if field.validator?
    catch err
      return callback err
    
    fixed = {}
    for field in @spec.fieldsWithDefault
      do (field) ->
        fixed[field.key] = field.default
    for k, v of doc
      fixed[@spec.nameToKey[k]] = v
    
    @collection.insert fixed, callback

module.exports.Timestamp = mongodb.BSONNative.Timestamp