class Controller
  init: ->
    @flash = @session.flash ? {}
    delete @session.flash

  execute: (action) ->
    throw new Error "Could not find #{action} in #{@_name}" if not this[action]?
    @_action = action
    
    x = 0
    next = (err) =>
      return @error err if err?
      return this[action].call this if x is @_filters.length
      filter = @_filters[x++]
      return next() if filter.only? and not (action in filter.only)
      if typeof filter.method is 'string'
        this[filter.method].call this, next
      else if typeof filter.method is 'function'
        filter.method.call this, next
    next()

  error: (err) ->
    @_responder.next err
  unauthorized: ->
    @_responder.unauthorized.apply @_responder, arguments
  render: (view, data, options) ->
    if arguments.length is 0
      @_view = @_action
      data = this
    else if typeof view is 'string'
      @_view = view
      data ?= this
    else
      @_view = @_action
      options = data
      data = view
      
    @_responder.render this, data, options
  redirect_to: (url, options) ->
    if options?.notice?
      @session.flash ?= {}
      @session.flash.notice = options.notice
    if options?.error?
      @session.flash ?= {}
      @session.flash.error = options.error
    @_responder.redirect_to url
    
  # options: httpOnly, secure, expires, maxAge
  set_cookie: (name, value, options) ->
    @_responder.res.cookie name, value, options
  set_headers: (headers) ->
    @_responder.set_headers {headers: headers}
    
  clear_cookie: (name) ->
    @_responder.res.clearCookie name
    
  stylesheet_link_tag: (filename) ->
    return '<link type="text/css" rel="stylesheet" href="/css/' + filename + '.css">'
    
  link_to: (text, link) ->
    return '<a href="' + link + '">' + text + '</a>'
    
module.exports = Controller