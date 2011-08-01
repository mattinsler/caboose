Compiler = require '../compiler'
Spec = require './spec'
Model = require './model'
Plugins = require '../plugins'

plugins = Plugins.get 'models', 'compiler'
console.log plugins

createValidator = (field, config) ->
  validators = []
  if config.presence?
    validators.push (model) ->
      throw new Error "Validation Error: Presence [#{field.name}]" if not model[field.name]
  (model) ->
    v model for v in validators

class ModelCompiler extends Compiler
  add_field: (type, name, options) ->
    field =
      type: type,
      name: name,
      key: options?.key ? name,
      get: options?.get ? (v) -> v,
      set: options?.set ? null,
      default: options?.default ? null,
      index: options?.index
    field.validator = if options?.validates? then createValidator field, options.validates else null
    @spec.fields.push field
    field
  
  add_static: (name, method) ->
    @spec.statics[name] = method
  
  add_method: (name, method) ->
    @spec.methods[name] = method

  add_calculated_field: (name, method) ->
    @spec.calculated_field[name] = method
  
  precompile: ->
    @spec = {
      fields: []
      statics: {}
      methods: {}
      calculated_fields: {}
    }
    
    @name = /class\W+([^\W]+)\W+extends\W+Model/.exec(@code)[1]
    throw new Error 'Could not find a model defined' if not @name?
  
    @scope.Model = class EmptyClass
    @scope.collection = (name) =>
      @collection_name = name
    @scope.method = (name, method) =>
      @add_method name, method
    @scope.static = (name, method) =>
      @add_static name, method
  
    for type in ['string', 'long', 'object_id', 'timestamp', 'db_ref', 'binary', 'code']
      do (type) =>
        @scope[type] = (name, options) =>
          @add_field type, name, options
    @scope.object = (name, options, structure) =>
      @add_field 'object', name, options
      # console.log "structure: #{structure}"
    @scope.array = (name, options, structure) =>
      @add_field 'array', name, options
      # console.log "structure: #{structure}"
      
    @add_field 'object_id', 'id', key: '_id', index: true
      
    add_to_scope = (k, v) =>
      @scope[k] = =>
        v.apply this, arguments

    if plugins.scope?
      for plugin in plugins.scope
        add_to_scope k, v for k, v of plugin
          
    if plugins.precompile?
      plugin.call this for plugin in plugins.precompile
      
  postcompile: ->
    if plugins.postcompile?
      plugin.call this for plugin in plugins.postcompile
  
  respond: ->
    new Model @name, @collection_name ? @name, new Spec @spec
    
module.exports = ModelCompiler