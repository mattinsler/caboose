Model = require './model'
Query = require './query'
Promise = Caboose.exports.promise

build = ->
  model = class extends Model
    constructor: ->
      super
      @__init__()
  
  Object.defineProperty model, '__super__', {enumerable: false}
  Object.defineProperty model, '__Query__', {value: class extends Query, enumerable: false}
  Object.defineProperty model, '__Promise__', {value: class extends Promise, enumerable: false}

  model::__init__ = ->
    Object.defineProperty @, '__type__', {value: model, enumerable: false}
  
  # non-enumerable Model properties
  for prop in ['__ensure_collection__']
    Object.defineProperty model, prop, {value: Model[prop], enumerable: false}
  # private properties
  Object.defineProperty model, '__type__', {value: model, enumerable: false}
  for prop in ['name', 'short_name']
    Object.defineProperty model, "__#{prop}__", {value: this[prop], enumerable: false}
  
  field_names = ['Long', 'ObjectID', 'Timestamp', 'DBRef', 'Binary', 'Code']
  Object.defineProperty(model, fn, {value: Model[fn], enumerable: false}) for fn in field_names
  
  plugin.build?.call(this, model) for plugin in Builder.plugins.reverse()

  model

class Builder
  @add_plugin: (opts) ->
    if opts.name?
      for plugin in @plugins
        throw new Error("[Plugin #{opts.name}] another caboose-model plugin already exists with the same name") if opts.name is plugin.name
    @plugins.push opts
  
  constructor: (name) ->
    Object.defineProperty @, 'name', {value: name, enumerable: false}
    Object.defineProperty @, 'short_name', {value: Caboose.registry.split(@name).join('_'), enumerable: false}
    
    plugin.initialize?.apply(this) for plugin in Builder.plugins
    
    Object.defineProperty @, 'build', {value: build, enumerable: false}

    for plugin in Builder.plugins
      do (plugin) =>
        if plugin.name? and plugin.execute?
          @[plugin.name] = ->
            plugin.execute.apply(this, arguments)
            this

Builder.plugins = [{
  name: 'static'
  initialize: -> Object.defineProperty @, '_statics', {value: {}, enumerable: false}
  execute: (name, method) -> @_statics[name] = method
  build: (model) ->
    for k, v of @_statics
      model[k] = v
}, {
  name: 'instance'
  initialize: -> Object.defineProperty @, '_instances', {value: {}, enumerable: false}
  execute: (name, method) -> @_instances[name] = method
  build: (model) ->
    for k, v of @_instances
      model::[k] = v
}, {
  name: 'property'
  initialize: -> Object.defineProperty @, '_properties', {value: {}, enumerable: false}
  execute: (name, method) -> @_properties[name] = method
  build: (model) ->
    return if Object.keys(@_properties).length is 0
    
    init = model::__init__
    _properties = @_properties
    model::__init__ = ->
      init.apply(this, arguments)
      for k, v of _properties
        Object.defineProperty @, k, {get: v, enumerable: true}
}, {
  name: 'before_save',
  initialize: -> Object.defineProperty @, '_before_saves', {value: [], enumerable: false}
  execute: (method) -> @_before_saves.push method
  build: (model) ->
    Object.defineProperty model, '_before_save', {value: @_before_saves, enumerable: false}
}, {
  name: 'store_in',
  execute: (collection_name) -> @_store_in = collection_name
  build: (model) ->
    Object.defineProperty model, '__collection_name__', {value: @_store_in, enumerable: false}
}, {
  name: 'use_connection',
  execute: (connection_name) -> @_use_connection = connection_name
  build: (model) ->
    Object.defineProperty model, '__connection_name__', {value: @_use_connection, enumerable: false}
}]

module.exports = Builder
