_ = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()
try
  Model = require('caboose-model').Model
catch e
  # no op

class FormBuilder
  constructor: (@context, @obj, @opts) ->
    @opts.action = (@opts.action || 'new').toLowerCase()
    throw new Error('action can only be new, create, edit, update or destroy') unless @opts.action in ['new', 'create', 'edit', 'update', 'destroy']
    if @opts.method?
      @opts.method = @opts.method.toUpperCase()
    else
      switch @opts.action
        when 'new', 'create' then @opts.method = 'POST'
        when 'edit', 'update' then @opts.method = 'PUT'
        when 'destroy' then @opts.method = 'DELETE'
    
    @opts.as = @obj.__type__.__short_name__ if !@opts.as? and Model? and @obj instanceof Model
    @opts.as ?= 'data'
    
    @opts.path ?= @context.request.url
    
    @html_opts = _(@opts).clone()
    delete @html_opts[k] for k in ['action', 'method', 'as', 'path']

  _field_name: (field) ->
    "#{@opts.as}[#{field}]"
    
  toString: ->
    buf = [@context.form_tag(@opts.path, _.extend({method: 'POST'}, @html_opts))]
    unless Caboose.app.config.controller?.csrf?.enabled is false
      buf.push(@context.hidden_field_tag('_csrf', @context.session._csrf))
    if @opts.method in ['PUT', 'DELETE']
      buf.push(@context.hidden_field_tag('_method', @opts.method))
    buf.join("\n")
      
  end: ->
    @ended = true
    @context.form_tag_end()
  
  label: (field, options) ->
    @context.label_tag(_(field).humanize(), _.extend({}, {for: @_field_name(field)}, options))
  
  text: (field, options) ->
    field_name = @_field_name(field)
    @context.text_field_tag(options.name || field_name, @obj[field] || '', _(id: field_name).extend(options))
  
  password: (field, options) ->
    field_name = @_field_name(field)
    @context.password_field_tag(options.name || field_name, @obj[field] || '', _(id: field_name).extend(options))
    
  textarea: (field, options) ->
    field_name = @_field_name(field)
    @context.text_area_tag(options.name || field_name, @obj[field] || '', _(id: field_name).extend(options))
  
  hidden: (field, options) ->
    field_name = @_field_name(field)
    @context.hidden_field_tag(options.name || field_name, @obj[field] || '', _(id: field_name).extend(options))
    
  select: (field, values, options) ->
    field_name = @_field_name(field)
    @context.select_tag(options.name || field_name, @obj[field] || '', values, _(id: field_name).extend(options))
  
  submit: (text, options) ->
    if typeof text isnt 'string'
      options = text
      text = null
    @context.submit_tag(text, options)

module.exports = {
  form_for: (obj, opts) ->
    unless opts?
      opts = obj
      obj = {}
    new FormBuilder(@, obj, opts)

  csrf_tag: ->
    @hidden_field_tag('_csrf', @session._csrf)
}
