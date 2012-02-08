Responder = require './responder'

class Controller
  constructor: (req, res, next) ->
    @_responder = new Responder(req, res, next)
    @flash = @session.flash ? {}
    delete @session.flash

  _execute: (action) ->
    throw new Error "Could not find #{action} in #{@_name}" if not this[action]?
    @_action = action
    
    x = 0
    next = (err) =>
      return @error err if err?
      return this[action].call(this) if x is @_before_actions.length
      filter = @_before_actions[x++]
      return next() if filter.only? and not (action in filter.only)
      if typeof filter.method is 'string'
        return next(new Error("Filter #{filter.method} does not exist")) unless this[filter.method]?
        this[filter.method].call(this, next)
      else if typeof filter.method is 'function'
        filter.method.call(this, next)
    next()

  not_found: (err) ->
    @_responder.not_found err
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
      
    @_responder.render(this, data, options)
  redirect_to: (url, options) ->
    if options?
      @session.flash = options
    @_responder.redirect_to url
  respond: () ->
    @responder.respond
    
  # options: httpOnly, secure, expires, maxAge
  set_cookie: (name, value, options) ->
    @_responder.res.cookie name, value, options
  set_headers: (headers) ->
    @_responder.set_headers {headers: headers}
    
  clear_cookie: (name, options) ->
    options or= {}
    options.expires = new Date(0)
    # @_responder.req.cookies[name] = null
    @_responder.res.cookie name, null, options
    # @_responder.res.cookie name, null
    
module.exports = Controller
