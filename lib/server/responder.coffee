ejs = require 'ejs'

class Responder
  constructor: (@viewFactory, @req, @res, @next) ->
    # console.log headers: @req.headers, url: @req.url, query: @req.query, params: @req.params
    
  render: (data) ->
    # return res.send 404 if not @view?.htmlTemplate?
    view = @viewFactory.create()
    try
      html = ejs.render view.html.template, {
        locals: data,
        filename: view.html.filename
      }
      @res.send html, 200
    catch err
      @next err
      
  redirect_to: (url) ->
    @res.redirect url

module.exports = Responder