_ = require 'underscore'
Path = require '../../path'
consolidate = require 'consolidate'
ViewResolver = require '../view_resolver'

render_view = (engine, view_path, local_data, callback) ->
  try
    consolidate[engine] view_path, local_data, callback
  catch err
    console.error "The #{engine} view engine is not installed. To fix this, run 'caboose view-engine install #{engine}'" if err.message is "Cannot find module '#{engine}'"
    callback(err)

# {
#   code: 
#   content: (Error | 'html' | string)
#   controller:
#   view:
#   options: {
#     layout: 
#   }
# }
module.exports = (opts, callback) ->
  DEFAULT_HELPERS = _.extend({}, require('../helpers/asset_helper'), require('../helpers/view_helper'), require('../helpers/form_helper'))

  view = opts.view
  controller = opts.controller
  options = opts.options
  
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
    partial_locals = _.extend({partial: render_partial}, DEFAULT_HELPERS, controller._helpers, controller, partial_data)
    partial_view = ViewResolver.resolve_view(controller._short_name, partial_view, controller.params.format, true)
    partial_key = "PARTIAL[#{render_count}]"

    if Array.isArray(partial_data)
      array_data = Array::slice.apply(partial_data)
      array_done = _.after partial_data.length, -> done(null, array_data.join('\n'), partial_key)
      partial_data.forEach (item, idx) ->
        partial_array_locals = _.extend({}, partial_locals)
        partial_array_locals[partial_var] = item
        render_view partial_view.extension, partial_view.path, partial_array_locals, (err, partial_text) ->
          return done(err) if err?
          array_data[idx] = partial_text
          array_done()
    else
      render_view partial_view.extension, partial_view.path, partial_locals, (err, partial_text) ->
        done(err, partial_text, partial_key)

    partial_key

  locals = _.extend({partial: render_partial}, DEFAULT_HELPERS, controller._helpers, controller)
  # console.log locals

  view_file = ViewResolver.resolve_view(controller._short_name, view, controller.params.format || 'html')
  return callback(new Error("No view found for #{controller._short_name}##{view}.html")) unless view?
  render_view view_file.extension, view_file.path, locals, (err, text) ->
    return done(err, text) if err? or (options?.layout? and !options.layout)

    layout = ViewResolver.resolve_layout(options?.layout || controller, controller.params.format)
    return done(err, text) unless layout?

    locals.yield = -> text
    render_view layout.extension, layout.path, locals, done
