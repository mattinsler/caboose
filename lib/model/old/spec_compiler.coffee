Compiler = require '../compiler'
Spec = require './spec'

# createValidator = (field, config) ->
#   validators = []
#   if config.presence?
#     validators.push (model) ->
#       throw new Error "Validation Error: Presence [#{field.name}]" if not model[field.name]
#   (model) ->
#     v model for v in validators

class SpecCompiler extends Compiler
  constructor: -> super()
  
  add_field: (name, options) ->
    options.name = name
    options.key ?= name
    @spec.fields.push options
    options
    # field =
    #   name: name,
    #   type: options.type,
    #   key: options?.key ? name,
    #   get: options?.get ? null,
    #   set: options?.set ? null,
    #   default: options?.default ? null,
    #   index: options?.index ? false
    # field.validator = if options?.validates? then createValidator field, options.validates else null
    # @spec.fields.push field
    # field
  
  find_field_by_name: (name) ->
    for field in @spec.fields
      return field if field.name is name
    null
  
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
    
    @scope.Model = class EmptyClass
    @scope.store_in = (collection_name) => @collection_name = collection_name
    @scope.method = => @add_method.apply this, arguments
    @scope.static = => @add_static.apply this, arguments
    @scope.field = => @add_field.apply this, arguments

    @apply_scope_plugins 'models'
    @apply_precompile_plugins 'models'

  postcompile: ->
    @apply_postcompile_plugins 'models'
  
  respond: ->
    @response = new Spec @spec
    
module.exports = SpecCompiler