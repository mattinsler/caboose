ejs = require 'ejs'

class Responder
  constructor: (@layoutFactory, @viewFactory, @req, @res, @next) ->
    @_renderers = {
      html: (data) =>
        html = @render_html data
        @res.contentType 'text/html'
        @res.send html, 200
      json: (data) =>
        @res.contentType 'application/json'
        @res.send data, 200
    }

  render_html: (data) ->
    http = global.app.config.http
    locals = {
      server: {
        base_url: "http://#{http.host}#{(if http.port is 80 then '' else ':' + http.port)}"
      }
    }
    locals[k] = v for k, v of data

    view = @viewFactory.create()
    html = ejs.render view.html.template, {
      locals: locals
      filename: view.html.filename
    }
    if @layoutFactory?
      layout = @layoutFactory.create()
      data.yield = -> html
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

  render: (data, options) ->
    format = @req.params.format ? 'html'
    renderer = @_renderers[format]
    @set_headers options
    @res.send 404 unless renderer?
    try
      renderer data
    catch err
      console.dir err.stack
      @next err
    
    # return res.send 404 if not @view?.htmlTemplate?
    
  unauthorized: (options) ->
    @set_headers options
    @res.send 401
      
  redirect_to: (url, options) ->
    @set_headers options
    @res.redirect url

module.exports = Responder