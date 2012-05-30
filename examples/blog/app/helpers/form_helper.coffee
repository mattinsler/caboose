_ = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()
Model = require('caboose-model').Model

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
    
    @opts.as = @obj.__type__.__short_name__ if !@opts.as? and @obj instanceof Model
    @opts.as ?= 'data'
    
    @opts.path ?= @context.request.url

  _field_name: (field) ->
    "#{@opts.as}[#{field}]"
    
  toString: ->
    buf = [@context.form_tag(@opts.path, method: 'POST')]
    if @opts.method in ['PUT', 'DELETE']
      buf.push(@context.hidden_field_tag('_method', @opts.method))
    buf.join("\n")
      
  end: ->
    @ended = true
    @context.form_tag_end()
  
  label: (field) ->
    @context.label_tag(_(field).humanize(), for: @_field_name(field))
  
  text: (field) ->
    @context.text_field_tag(@_field_name(field), @obj[field] || '')
  
  password: (field) ->
    @context.password_field_tag(@_field_name(field), @obj[field] || '')
    
  textarea: (field) ->
    @context.text_area_tag(@_field_name(field), @obj[field] || '')
  
  submit: (text) ->
    @context.submit_tag(text)

module.exports = {
  form_for: (obj, opts) ->
    unless opts?
      opts = obj
      obj = {}
    new FormBuilder(@, obj, opts)
}
