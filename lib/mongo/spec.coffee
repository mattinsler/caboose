createValidator = (field, config) ->
  validators = []
  if config.presence?
    validators.push (model) ->
      throw new Error "Validation Error: Presence [#{field.name}]" if not model[field.name]
  (model) ->
    v model for v in validators

module.exports = class Spec
  constructor: ->
    @fields = []
    @fieldsWithDefault = []
    @nameToKey = {}
    @keyToName = {}

  _field: (type, name, options) ->
    field =
      type: type,
      name: name,
      key: options?.key ? name,
      get: options?.get ? (v) -> v,
      default: options?.default ? null
    field.validator = if options?.validates? then createValidator field, options.validates else null
    @fields.push field
    @nameToKey[field.name] = field.key
    @keyToName[field.key] = field.name
    @fieldsWithDefault.push field if field.default?
      
  string: (name, options) -> @_field 'string', name, options
  long: (name, options) -> @_field 'long', name, options
  object_id: (name, options) -> @_field 'object_id', name, options
  timestamp: (name, options) -> @_field 'timestamp', name, options
  db_ref: (name, options) -> @_field 'db_ref', name, options
  binary: (name, options) -> @_field 'binary', name, options
  code: (name, options) -> @_field 'code', name, options