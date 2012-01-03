Model = require './model'

build = ->
  model = class extends Model
    constructor: ->
      super
      @init()
  Object.defineProperty model, '__super__', {enumerable: false}
  model::init = ->
    Object.defineProperty this, '_type', {value: model, enumerable: false}
  # non-enumerable Model properties
  for prop in ['_ensure_collection']
    Object.defineProperty model, prop, {value: Model[prop], enumerable: false}
  # private properties
  Object.defineProperty model, '_type', {value: model, enumerable: false}
  for prop in ['name', 'properties']
    Object.defineProperty model, "_#{prop}", {value: this[prop], enumerable: false}
  
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
    
    plugin.initialize?.apply(this) for plugin in Builder.plugins
    
    Object.defineProperty @, 'properties', {value: {}, enumerable: false}
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
  execute: (name, method) ->
    @_statics[name] = method
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
  name: 'before_save',
  initialize: -> Object.defineProperty @, '_before_saves', {value: [], enumerable: false}
  execute: (method) -> @_before_saves.push method
  build: (model) ->
    Object.defineProperty model, '_before_save', {value: @_before_saves, enumerable: false}
}, {
  name: 'store_in',
  execute: (collection_name) -> @_store_in = collection_name
  build: (model) ->
    Object.defineProperty model, '_collection_name', {value: @_store_in, enumerable: false}
}]

module.exports = Builder
