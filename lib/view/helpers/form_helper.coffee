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
    
    @opts.as = @obj._type._short_name if !@opts.as? and Model? and @obj instanceof Model
    @opts.as ?= 'data'
    
    @opts.path ?= @context.request.url

  _field_name: (field) ->
    "#{@opts.as}[#{field}]"
    
  toString: ->
    buf = [@context.form_tag(@opts.path, method: 'POST')]
    unless Caboose.app.config.controller?.csrf?.enabled is false
      buf.push(@context.hidden_field_tag('_csrf', @session._csrf))
    if @opts.method in ['PUT', 'DELETE']
      buf.push(@context.hidden_field_tag('_method', @opts.method))
    buf.join("\n")
      
  end: ->
    @ended = true
    @context.form_tag_end()
  
  label: (field, options) ->
    @context.label_tag(_(field).humanize(), _.extend({}, {for: @_field_name(field)}, options))
  
  text: (field, options) ->
    @context.text_field_tag(@_field_name(field), @obj[field] || '', options)
  
  password: (field, options) ->
    @context.password_field_tag(@_field_name(field), @obj[field] || '', options)
    
  textarea: (field, options) ->
    @context.text_area_tag(@_field_name(field), @obj[field] || '', options)
  
  hidden: (field, options) ->
    @context.hidden_field_tag(@_field_name(field), @obj[field] || '', options)
    
  select: (field, values, options) ->
    @context.select_tag(@_field_name(field), @obj[field] || '', values, options)
  
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
