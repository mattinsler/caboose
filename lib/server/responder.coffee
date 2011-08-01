ejs = require 'ejs'

class Responder
  constructor: (@viewFactory, @req, @res, @next) ->
    @_renderers = {
      html: (data) =>
        view = @viewFactory.create()
        html = ejs.render view.html.template, {
          locals: data,
          filename: view.html.filename
        }
        @res.contentType 'text/html'
        @res.send html, 200
      json: (data) =>
        @res.contentType 'application/json'
        @res.send data, 200
    }

  render: (data) ->
    format = @req.params.format ? 'html'
    renderer = @_renderers[format]
    @res.send 404 unless renderer?
    try
      renderer data
    catch err
      @next err
    
    # return res.send 404 if not @view?.htmlTemplate?
      
  redirect_to: (url) ->
    @res.redirect url

module.exports = Responder