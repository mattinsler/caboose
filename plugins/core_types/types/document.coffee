Type = require('caboose').Model.Type

exports.Document = class Document extends Type
  constructor: (spec, options) -> super(spec, options)
  to_plain: (old_doc, new_doc, value) ->
    super old_doc, new_doc, value
    
    if @options.spec? and new_doc[@options.key]?
      new_doc[@options.key] = @options.spec.to_plain new_doc[@options.key]