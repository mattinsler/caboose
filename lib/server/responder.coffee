_ = require 'underscore'
ejs = require 'ejs'
path = require 'path'
ViewFactory = require '../view/view_factory'

class Responder
  constructor: (@req, @res, @next) ->
    @_renderers = {
      html: (controller, data, options) =>
        html = @render_html controller, data, options
        @res.contentType 'text/html'
        @res.send html, 200
      json: (controller, data, options) =>
        @res.contentType 'application/json'
        @res.send data, 200
    }

  render_html: (controller, data, options) ->
    locals = {}
    
    for helper in controller._helpers
      if typeof helper isnt 'string'
        _.extend(locals, helper)
    _.extend(locals, data, controller)

    view_factory = ViewFactory.compile Caboose.path.views.join(controller._short_name, "#{controller._view}.html.ejs").toString()
    if options?.layout?
      layout_factory = ViewFactory.compile(Caboose.path.views.join('layouts', options.layout + '.html.ejs').toString()) unless !options.layout
    else
      layout_factory = ViewFactory.compile(Caboose.path.views.join('layouts', controller._short_name + '.html.ejs').toString()) ||
                       ViewFactory.compile(Caboose.path.views.join('layout.html.ejs').toString())

    if view_factory?
      view = view_factory.create()
      html = ejs.render view.html.template, {
        locals: locals
        filename: view.html.filename
      }
      if layout_factory?
        layout = layout_factory.create()
        locals.yield = -> html
        layoutHtml = ejs.render layout.html.template, {
          locals: locals
          filename: layout.html.filename
        }
        html = layoutHtml
    html

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