Model = require './model'

build = ->
  # pre-build plugins
  for k, v of @properties
    Builder.plugins[k].pre_build.apply this, v if Builder.plugins[k].pre_build?

  model = class extends Model
    constructor: ->
      super
      @init()
  model::init = ->
    Object.defineProperty this, '_type', {value: model, enumerable: false}
  # non-enumerable Model properties
  for prop in ['_ensure_collection']
    Object.defineProperty model, prop, {value: Model[prop], enumerable: false}
  # private properties
  Object.defineProperty model, '_type', {value: model, enumerable: false}
  for prop in ['name', 'properties', 'before_save']
    Object.defineProperty model, "_#{prop}", {value: this[prop], enumerable: false}

  for k, v of @instance_methods
    model::[k] = v
  for k, v of @statics
    model[k] = v

  @model = model
  # post-build plugins
  for k, v of @properties
    Builder.plugins[k].post_build.apply this, v if Builder.plugins[k].post_build?

  Object.defineProperty @model, '__super__', {enumerable: false}
  @model

class Builder
  @plugins = {
    store_in: {
      post_build: (collection_name) ->
        Object.defineProperty @model, '_collection_name', {value: collection_name, enumerable: false}
    }
  }
  
  constructor: (name) ->
    Object.defineProperty @, 'name', {value: name, enumerable: false}
    
    for field in Object.keys(Builder.plugins)
      do (field) =>
        this[field] = ->
          @properties[field] = Array::slice.call arguments
          this
    
    Object.defineProperty @, 'statics', {value: {}, enumerable: false}
    Object.defineProperty @, 'instance_methods', {value: {}, enumerable: false}
    Object.defineProperty @, 'properties', {value: {}, enumerable: false}
    Object.defineProperty @, 'before_save', {value: [], enumerable: false}
    Object.defineProperty @, 'build', {value: build, enumerable: false}

  static: (name, method) ->
    @statics[name] = method
    this
  instance: (name, method) ->
    @instance_methods[name] = method
    this
  before_save: (method) ->
    @before_save.push method
    this

module.exports = Builder
