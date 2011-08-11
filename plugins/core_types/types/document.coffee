Type = require('caboose').Model.Type
Spec = require('caboose').Model.Spec

field = () ->
  console.log 'field'
  console.log argument

exports.Document = class Document extends Type
  @type: 'Document'
  
  constructor: (spec, options) ->
    super spec, options

    if @options.spec?
      if typeof @options.spec is 'function'
        @options.spec = Spec.compile @options.spec
      else if typeof @options.spec is 'object' and @options.spec.type is 'model'
        @options.spec = @options.spec.spec
      
  to_plain: (old_doc, new_doc, value) ->
    super old_doc, new_doc, value
    
    if @options.spec? and new_doc[@options.key]?
      new_doc[@options.key] = @options.spec.to_plain new_doc[@options.key]