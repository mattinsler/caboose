_ = require 'underscore'
Path = require '../path'
consolidate = require 'consolidate'

resolve_view = (root, view, format, is_partial) ->
  view = new Path(view)
  view = if view.is_absolute() then new Path(view.path.replace(/^\/+/, '')) else new Path(root).join(view.path)
  name = (if is_partial and view.filename[0] isnt '_' then '_' else '') + view.filename
  try
    files = (if view.is_absolute() then new Path(view.dirname) else Caboose.path.views.join(view.dirname)).readdir_sync()
    _(files).find((f) -> f.basename is "#{name}.#{format}") || _(files).find((f) -> f.basename is name)
  catch e

resolve_layout = (controller, format) ->
  layouts_dir = Caboose.path.views.join('layouts')
  return resolve_view(layouts_dir, controller, format) if typeof controller is 'string'
  
  c = Caboose.registry.get(controller._name)
  while c
    layout = resolve_view(layouts_dir, c.short_name, format)
    return layout if layout?
    c = Caboose.registry.get(c._extends)
  null

compile_helpers = (controller) ->
  helpers = {}
  _.extend(helpers, helper) for helper in controller._helpers
  helpers

render = (controller, data, options, callback) ->
  counter = 0
  render_count = 1
  
  rendered_text = null
  partial_table = {}
  done = (err, str, partial_id) ->
    return callback(err) if err?
    
    if partial_id?
      partial_table[partial_id] = str
    else
      rendered_text = str
    
    if ++counter is render_count
      rendered_text = rendered_text.replace(id, text) for id, text of partial_table
      callback(null, rendered_text)
  
  render_partial = (partial_view, partial_data) ->
    ++render_count

    partial_var = new Path(partial_view).filename.replace(/^\_+/, '')
    partial_locals = _.extend({}, compile_helpers(controller), partial_data || data || controller)
    partial_locals.partial = render_partial
    partial_view = resolve_view(controller._short_name, partial_view, controller.params.format, true)
    partial_key = "PARTIAL[#{render_count}]"
    
    if Array.isArray(partial_data)
      array_data = Array::slice.apply(partial_data)
      array_done = _.after partial_data.length, -> done(null, array_data.join('\n'), partial_key)
      partial_data.forEach (item, idx) ->
        partial_array_locals = _.extend({}, partial_locals)
        partial_array_locals[partial_var] = item
        consolidate[partial_view.extension] partial_view.path, partial_array_locals, (err, partial_text) ->
          return done(err) if err?
          array_data[idx] = partial_text
          array_done()
    else
      consolidate[partial_view.extension] partial_view.path, partial_locals, (err, partial_text) ->
        done(err, partial_text, partial_key)
    
    partial_key
  
  locals = _.extend({}, compile_helpers(controller), data || controller)
  locals.partial = render_partial
  
  view = resolve_view(controller._short_name, controller._view, controller.params.format)
  consolidate[view.extension] view.path, locals, (err, text) ->
    return done(err, text) if err? or (options?.layout? and !options.layout)
    
    layout = resolve_layout(options?.layout || controller, controller.params.format)
    return done(err, text) unless layout?
    
    locals.yield = -> text
    consolidate[layout.extension] layout.path, locals, done

class Responder
  constructor: (@req, @res, @next) ->
    @_renderers = {
      html: (controller, data, options) =>
        render controller, data, options, (err, html) =>
          return console.error(err.stack) if err?
          @res.contentType 'text/html'
          @res.send html, 200
      json: (controller, data, options) =>
        @res.contentType 'application/json'
        @res.send data, 200
    }

  set_headers: (options) ->
    set_header = (k, v) => @res.header(k, v)
    if options?.headers?
      set_header k, v for k, v of options.headers

  render: (controller, data, options) ->
    format = @req.params.format
    renderer = @_renderers[format]
    @set_headers options
    @res.send 404 unless renderer?
    try
      renderer controller, data, options
    catch err
      console.error err.stack
      @next err
    
    # return res.send 404 if not @view?.htmlTemplate?
  
  not_found: (err) ->
    return @res.send err, 404 if err?
    @res.send 404
  
  unauthorized: (options) ->
    @set_headers options
    @res.send 401
      
  redirect_to: (url, options) ->
    @set_headers options
    @res.redirect url

module.exports = Responder
