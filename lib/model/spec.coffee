createValidator = (field, config) ->
  validators = []
  if config.presence?
    validators.push (model) ->
      throw new Error "Validation Error: Presence [#{field.name}]" if not model[field.name]
  (model) ->
    v model for v in validators

class Spec
  constructor: (@fields) ->
    @indexes = []
    @_validators = []
    for field in @fields
      @_validators.push field.validator if field.validator?
      if field.index?
        idx = fields: []
        idx.fields.push field
        @indexes.push idx
    @Wrapper = class Wrapper
      constructor: (fields, doc) ->
        Object.defineProperty this, 'doc', value: doc
        for field in fields
          (=>
            f = field
            Object.defineProperty this, f.name,
              enumerable: true
              get: -> f.get @doc[f.key]
          )()
  
  wrap: (obj) ->
    if obj? then new @Wrapper @fields, obj else null
    
  validate: (obj) ->
    try
      v obj for v in @_validators
    catch err
      return err
    null
    
  filter: (obj, filters...) ->
    newObj = {}
    for field in @fields
      handled = 0
      handled |= filter.call newObj, obj, field for filter in filters
      Spec._copy.call newObj, obj, field if handled is 0
    newObj

Spec.nameToKey = (doc, field) ->
  if doc[field.name]?
    this[field.key] = doc[field.name]
    return true
  false

Spec.keyToName = (doc, field) ->
  if doc[field.key]?
    this[field.name] = doc[field.key]
    return true
  false

Spec._copy = (doc, field) ->
  if doc[field.name]?
    this[field.name] = doc[field.name]
    return true
  false

Spec.applyDefault = (doc, field) ->
  if not doc[field.name]? and field.default?
    this[field.name] = field.default?() ? field.default
    return true
  false

# Spec.create = (config) ->
#   class Configurator
#     constructor: () ->
#       @fields = []
#     _field: (type, name, options) ->
#       field =
#         type: type,
#         name: name,
#         key: options?.key ? name,
#         get: options?.get ? (v) -> v,
#         default: options?.default ? null,
#         index: options?.index
#       field.validator = if options?.validates? then createValidator field, options.validates else null
#       @fields.push field
#       
#     string: (name, options) -> @_field 'string', name, options
#     long: (name, options) -> @_field 'long', name, options
#     object_id: (name, options) -> @_field 'object_id', name, options
#     timestamp: (name, options) -> @_field 'timestamp', name, options
#     db_ref: (name, options) -> @_field 'db_ref', name, options
#     binary: (name, options) -> @_field 'binary', name, options
#     code: (name, options) -> @_field 'code', name, options
#     object: (name, options, structure) ->
#       @_field 'object', name, options
#       # console.log 'structure: ' + structure
#     array: (name, options) -> @_field 'array', name, options
#     
#     index: (name, options) ->
#   
#   configurator = new Configurator()
#   config.call configurator
#   new Spec configurator.fields

module.exports = Spec