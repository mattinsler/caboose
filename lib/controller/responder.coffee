_ = require 'underscore'
mime = require 'mime'
View = require '../view/view'

class Responder
  constructor: (@req, @res, @next) ->
    # @_renderers = {
    #   html: (controller, data, options) =>
    #     render controller, data, options, (err, html) =>
    #       return console.error(err.stack) if err?
    #       @res.contentType 'text/html'
    #       @res.send html, 200
    #   json: (controller, data, options) =>
    #     @res.contentType 'application/json'
    #     @res.send data, 200
    # }

  set_headers: (options) ->
    set_header = (k, v) => @res.header(k, v)
    if options?.headers?
      set_header k, v for k, v of options.headers
  
  redirect_to: (url, options) ->
    @set_headers options
    @res.redirect url
  
  respond: (opts) ->
    # {
    #   code: 
    #   content: (Error | 'html' | string)
    #   controller:
    #   view:
    #   options:
    # }
    opts.code ?= 200
    opts.options ?= {}
    
    @set_headers opts.options
    
    status_class = Math.floor(opts.code / 100)
    return @res.redirect(opts.content, opts.code) if status_class is 3
    return @res.send(opts.content, opts.code) if opts.content?
    
    content_type = mime.lookup(@req.params.format)
    View.render content_type, opts, (err, content) =>
      return @next(err) if err?
      @res.header('Content-Type', content_type)
      @res.send(content, opts.code)

module.exports = Responder
