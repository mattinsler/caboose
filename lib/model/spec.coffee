class Spec
  constructor: (options) ->
    this[k] = v for k, v of options
    
    @indexes = []
    @_validators = []
    for field in @fields
      @_validators.push field.validator if field.validator?
      if field.index?
        idx = fields: []
        idx.fields.push field
        @indexes.push idx
    @Wrapper = class Wrapper
      constructor: (doc, fields, methods) ->
        Object.defineProperty this, 'doc', value: doc
        for field in fields
          (=>
            f = field
            Object.defineProperty this, f.name,
              enumerable: true
              get: -> f.get @doc[f.key], f
          )()
    for name, method of @methods
      @Wrapper::[name] = method
  
  wrap: (obj) ->
    if obj? then new @Wrapper obj, @fields else null
    
  validate: (obj) ->
    try
      v obj for v in @_validators
    catch err
      return err
    null
    
  filter: (obj, filters...) ->
    newObj = {}
    for field in @fields
      x = 0
      next = (key, value) ->
        if x < filters.length
          filters[x++] field, key, value, next
        else
          newObj[key] = value if value?
      value = obj[field.key] ? obj[field.name]
      # value = @filter value, filters if typeof value is 'object'
      next field.name, value
    newObj

  @NameToKey: (field, key, value, next) ->
    next field.key, value
    
  @ApplyDefault = (field, key, value, next) ->
    value = (field.default?() ? field.default) if not value? and field.default?
    next key, value
  
  @KeyToName = (field, key, value, next) ->
    next field.name, value
  
  @ApplySetter = (field, key, value, next) ->
    value = field.set value, field if field.set? and value?
    next key, value

module.exports = Spec