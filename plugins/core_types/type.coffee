module.exports = class Type
  constructor: (@spec, @options) ->
    @options.key ?= @options.name

  to_plain: (old_doc, new_doc, value) ->
    if value?
      new_doc[@options.key] = value
    else if @options.default?
      new_doc[@options.key] = @options.default?() ? @options.default

  to_query: (old_doc, new_doc, value) ->
    if value?
      new_doc[@options.key] = value