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
      filter.call newObj, obj, field for filter in filters
    newObj

Spec.nameToKey = (doc, field) ->
  this[field.key] = doc[field.name] if doc[field.name]?

Spec.keyToName = (doc, field) ->
  this[field.name] = doc[field.key] if doc[field.key]?

Spec.applyDefault = (doc, field) ->
  doc[field.name] = field.default?() ? field.default if not doc[field.name]? and field.default?

Spec.create = (config) ->
  class Configurator
    constructor: () ->
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
      
    string: (name, options) -> @_field 'string', name, options
    long: (name, options) -> @_field 'long', name, options
    object_id: (name, options) -> @_field 'object_id', name, options
    timestamp: (name, options) -> @_field 'timestamp', name, options
    db_ref: (name, options) -> @_field 'db_ref', name, options
    binary: (name, options) -> @_field 'binary', name, options
    code: (name, options) -> @_field 'code', name, options
    object: (name, options) -> @_field 'object', name, options
    
    index: (name, options) ->
  
  configurator = new Configurator()
  config.call configurator
  new Spec configurator.fields

module.exports = Spec