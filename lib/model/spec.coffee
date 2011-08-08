Type = require './type'

class Spec
  constructor: (options) ->
    # this[k] = v for k, v of options
    
    @indexes = []
    @statics = options.statics

    @name_to_field = {}
    @key_to_field = {}
    for field in options.fields
      type = new field.type this, field
      if type not instanceof Type
        console.log field.type.name
        throw new Error "#{type.name} #{field.name} must be a Type"
      @name_to_field[field.name] = type
      @key_to_field[field.key] = type
      
      if field.index
        @indexes.push {fields: [field]}

  validate: (doc) ->
    null
      
  to_plain: (old_doc) ->
    new_doc = {}
    for k, v of @name_to_field
      v.to_plain old_doc, new_doc, old_doc[k]
    new_doc
  
  from_server: (old_doc) ->
    new_doc = {}
    for k, v of @key_to_field
      v.from_server old_doc, new_doc, old_doc[k]
    new_doc
    
  to_query: (old_doc) ->
    new_doc = {}

    handle_field = (name, value) =>
      parts = name.split '.'
      return @name_to_field[name].to_query old_doc, new_doc, value if parts.length is 1
      
      x = 0
      spec = this
      key = []
      while x < parts.length
        if x is parts.length - 1
          if spec.name_to_field[parts[x]]?
            tmp = {}
            spec.name_to_field[parts[x]].to_query old_doc, tmp, value
            new_doc[(key.concat k).join '.'] = v for k, v of tmp
          return
        
        part = parts[x]
        field = spec.name_to_field[part]
        key.push field.options.key
        return unless field? and field instanceof Document
        if not field.options.spec?
          # console.log key.concat(parts.slice x + 1).join '.'
          new_doc[key.concat(parts.slice x + 1).join '.'] = value
          return

        spec = field.options.spec
        ++x
    
    for k, v of old_doc
      if k[0] is '$'
        new_doc[k] = this.to_query old_doc[k]
      else
        handle_field k, v
    new_doc


# class Spec
#   constructor: (options) ->
#     this[k] = v for k, v of options
#     
#     @indexes = []
#     @_validators = []
#     for field in @fields
#       @_validators.push field.validator if field.validator?
#       if field.index?
#         idx = fields: []
#         idx.fields.push field
#         @indexes.push idx
#     @Wrapper = class Wrapper
#       constructor: (doc, fields, methods) ->
#         Object.defineProperty this, 'doc', value: doc
#         for field in fields
#           (=>
#             f = field
#             Object.defineProperty this, f.name,
#               enumerable: true
#               get: -> f.get @doc[f.key], f
#           )()
#     for name, method of @methods
#       @Wrapper::[name] = method
#   
#   wrap: (obj) ->
#     if obj? then new @Wrapper obj, @fields else null
#     
#   validate: (obj) ->
#     try
#       v obj for v in @_validators
#     catch err
#       return err
#     null
#     
#   filter: (obj, filters...) ->
#     newObj = {}
#     for field in @fields
#       x = 0
#       next = (key, value) ->
#         if x < filters.length
#           filters[x++] field, key, value, next
#         else
#           newObj[key] = value if value?
#       value = obj[field.key] ? obj[field.name]
#       # value = @filter value, filters if typeof value is 'object'
#       next field.name, value
#     newObj
# 
#   @NameToKey: (field, key, value, next) ->
#     next field.key, value
#     
#   @ApplyDefault = (field, key, value, next) ->
#     value = (field.default?() ? field.default) if not value? and field.default?
#     next key, value
#   
#   @KeyToName = (field, key, value, next) ->
#     next field.name, value
#   
#   @ApplySetter = (field, key, value, next) ->
#     value = field.set value, field if field.set? and value?
#     next key, value

module.exports = Spec