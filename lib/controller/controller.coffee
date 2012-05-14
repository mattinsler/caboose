async = require 'async'
Responder = require './responder'

class Controller
  constructor: (req, res, next) ->
    Object.defineProperty @, '_responder', {value: new Responder(req, res, next)}
    @flash = @session?.flash ? {}
    # Object.defineProperty @, 'flash', {value: @session?.flash ? {}}
    delete @session.flash
  
  @after: (method_name, callback) ->
    Object.defineProperty(@, '_after', enumerable: false, value: {}) unless @_after?
    (@_after[method_name] ?= []).push callback

  @before: (method_name, callback) ->
    Object.defineProperty(@, '_before', enumerable: false, value: {}) unless @_before?
    (@_before[method_name] ?= []).push callback

  _apply_after: (method_name, args, next) ->
    return next() unless @constructor._after?[method_name]?
    async.series(@constructor._after[method_name].map((i) -> (cb) -> i.apply(@, [cb].concat(Array::slice.call(args)))), next)

  _apply_before: (method_name, args, next) ->
    return next() unless @constructor._before?[method_name]?
    async.series(@constructor._before[method_name].map((i) => (cb) => i.apply(@, [cb].concat(Array::slice.call(args)))), next)

  _execute: (action) ->
    throw new Error "Could not find #{action} in #{@_name}" if not @[action]?
    @_action = action
    
    @_apply_before '_execute', [action], (err) =>
      @error(err) if err?
      @[action].call(@, action)
  
  respond: -> @_responder.respond(arguments...)

  not_found: (err) ->
    @_responder.respond {
      code: 404
      content: if err instanceof Error then err else new Error(err)
    }
  
  unauthorized: (err) ->
    @_responder.respond {
      code: 401
      content: if err instanceof Error then err else new Error(err)
    }

  error: (err) -> @_responder.next err

  redirect_to: (url, flash) ->
    @session.flash = flash if flash?
    @_responder.respond {
      code: 302
      content: url
    }

  # render()
  # render(view)
  # render(opts)
  # render(view, opts)
  render: (view, options) ->
    view ?= @_action
    if view? and typeof view is 'object'
      options = view
      view = @_action
    throw new Error('View must be a string') if typeof view isnt 'string'
    
    @_responder.respond {
      code: 200
      controller: @
      view: view
      options: options
    }
    
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
