Model = require './model'
Query = require './query'
Promise = Caboose.exports.promise

build = (original_model) ->
  model = class extends Model
    constructor: ->
      super
      @__init__()
      original_model::constructor.apply(@, arguments)
  
  Object.defineProperty model, '__super__', {enumerable: false}
  Object.defineProperty model, '__Query__', {value: class extends Query, enumerable: false}
  Object.defineProperty model, '__Promise__', {value: class extends Promise, enumerable: false}

  initializers = @_initializers
  model::__init__ = ->
    Object.defineProperty @, '__type__', {value: model, enumerable: false}
    i.call(@) for i in initializers
  
  # non-enumerable Model properties
  for prop in ['__ensure_collection__']
    Object.defineProperty model, prop, {value: Model[prop], enumerable: false}
  # private properties
  Object.defineProperty model, '__type__', {value: model, enumerable: false}
  for prop in ['name', 'short_name']
    Object.defineProperty model, "__#{prop}__", {value: this[prop], enumerable: false}
  
  field_names = ['Long', 'ObjectID', 'Timestamp', 'DBRef', 'Binary', 'Code']
  Object.defineProperty(model, fn, {value: Model[fn], enumerable: false}) for fn in field_names
  
  plugin.build?.call(this, model, original_model) for plugin in Builder.plugins.reverse()

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
    # support for initializers
    Object.defineProperty @, '_initializers', {value: [], enumerable: false}
    
    plugin.initialize?.apply(this) for plugin in Builder.plugins
    
    Object.defineProperty @, 'build', {value: build, enumerable: false}

    for plugin in Builder.plugins
      do (plugin) =>
        if plugin.name? and plugin.execute?
          @[plugin.name] = ->
            plugin.execute.apply(this, arguments)
            this

Builder.plugins = [{
  # Static methods
  build: (model, original_model) ->
    return unless original_model?
    
    for k in Object.keys(original_model) when k isnt '__super__' and typeof original_model[k] is 'function'
      model[k] = original_model[k]
}, {
  # Instance methods
  build: (model, original_model) ->
    return unless original_model?
    
    for k in Object.keys(original_model::) when k isnt 'constructor' and typeof original_model::[k] is 'function'
      model::[k] = original_model::[k]
}, {
  # Getters and Setters
  build: (model, original_model) ->
    return unless original_model?
    
    is_properties_object = (obj) ->
      return false unless typeof obj is 'object'
      for k in Object.keys(obj)
        return false unless k in ['get', 'set'] and typeof obj[k] is 'function'
      true

    for k in Object.keys(original_model::) when typeof k isnt 'function'
      do (k) =>
        if is_properties_object(original_model::[k])
          # define everything at initialization
          @_initializers.push ->
            Object.defineProperty(@, '__values__', {enumerable: false, value: {}}) unless @.__values__?
            
            if @[k]?
              @__values__[k] = @[k]
              delete @[k]
            
            opts = {enumerable: true}
            
            if original_model::[k].set?
              opts.set = (value) -> @__values__[k] = original_model::[k].set.call(@, value)
            else
              opts.set = (value) -> @__values__[k] = value

            if original_model::[k].get?
              opts.get = -> original_model::[k].get.call(@, @__values__[k])
            else
              opts.get = -> @__values__[k]
            
            Object.defineProperty(@, k, opts)
        else
          model::[k] = original_model::[k]
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
