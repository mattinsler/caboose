module.exports = class Type
  constructor: (@spec, @options) ->
    @options.key ?= @options.name

  to_plain: (old_doc, new_doc, value) ->
    if value?
      new_doc[@options.key] = value
    else if @options.default?
      new_doc[@options.key] = @options.default?() ? @options.default
    
    if @options.set? and typeof @options.set is 'function' and new_doc[@options.key]?
      new_doc[@options.key] = @options.set new_doc[@options.key]
      
  from_server: (old_doc, new_doc, value) ->
    if value?
      new_doc[@options.name] = value
    # else if @options.default?
    #   new_doc[@options.key] = @options.default?() ? @options.default

  to_query: (old_doc, new_doc, value) ->
    if value?
      new_doc[@options.key] = value