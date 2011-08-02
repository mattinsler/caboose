Compiler = require '../compiler'
Spec = require './spec'
Model = require './model'

createValidator = (field, config) ->
  validators = []
  if config.presence?
    validators.push (model) ->
      throw new Error "Validation Error: Presence [#{field.name}]" if not model[field.name]
  (model) ->
    v model for v in validators

class ModelCompiler extends Compiler
  add_field: (name, options) ->
    field =
      name: name,
      type: options.type,
      key: options?.key ? name,
      get: options?.get ? null,
      set: options?.set ? null,
      default: options?.default ? null,
      index: options?.index ? false
    # field.validator = if options?.validates? then createValidator field, options.validates else null
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
    @scope.collection = (collection_name) => @collection_name = collection_name
    @scope.method = => @add_method.apply this, arguments
    @scope.static = => @add_static.apply this, arguments
    @scope.field = => @add_field.apply this, arguments

    @apply_scope_plugins 'models'
    @apply_precompile_plugins 'models'
      
  postcompile: ->
    @apply_postcompile_plugins 'models'
  
  respond: ->
    @response = new Model @name, @collection_name ? @name, new Spec @spec
    @apply_respond_plugins 'models'
    @response
    
module.exports = ModelCompiler