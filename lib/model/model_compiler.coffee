Compiler = require '../compiler'
Spec = require './spec'
Model = require './model'

module.exports = class ModelCompiler extends Compiler
  _init: ->
    @fields = []
    
  _field: (type, name, options) ->
    field =
      type: type,
      name: name,
      key: options?.key ? name,
      get: options?.get ? (v) -> v,
      default: options?.default ? null,
      index: options?.index
    field.validator = if options?.validates? then createValidator field, options.validates else null
    @fields.push field
  
  precompile: ->
    @_init()
    
    @name = /class\W+([^\W]+)\W+extends\W+Model/.exec(@code)[1]
    throw new Error 'Could not find a model defined' if not @name?
  
    @scope.Model = class EmptyClass
    @scope.collection = (name) =>
      @collection_name = name
  
    for type in ['string', 'long', 'object_id', 'timestamp', 'db_ref', 'binary', 'code']
      do (type) =>
        @scope[type] = (name, options) =>
          @_field type, name, options
    @scope.object = (name, options, structure) =>
      @_field 'object', name, options
      # console.log "structure: #{structure}"
    @scope.array = (name, options, structure) =>
      @_field 'array', name, options
      # console.log "structure: #{structure}"

    # @scope.index = (name, options) ->
  
  respond: ->
    new Model @name, @collection_name ? @name, new Spec @fields