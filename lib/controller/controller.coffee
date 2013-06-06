async = require 'async'
Responder = require './responder'

class Controller
  constructor: (req, res, next) ->
    # protect against being called twice...  this happened when the generated javascript syntax changed
    return if @__initialized__
    Object.defineProperty(@, '__initialized__', {enumerable: false, value: true})
    Object.defineProperty(@, '_responder', {writable: true, value: new Responder(req, res, next)})
    
    @flash = @session?.flash
    @flash = req.flash() if !@flash? or @flash is {}
    delete @session.flash
    
    @respond_with.callback = (err, data) =>
      @respond_with(err ? data)
    @respond_with.callback_with_fields = (fields) =>
      (err, data) =>
        @respond_with(err ? data, fields)
  
  @after: (method_name, callback) ->
    Object.defineProperty(@, '_after', enumerable: false, value: {}) unless @_after?
    (@_after[method_name] ?= []).push callback

  @before: (method_name, callback) ->
    Object.defineProperty(@, '_before', enumerable: false, value: {}) unless @_before?
    (@_before[method_name] ?= []).push callback

  _apply_after: (method_name, args, next) ->
    return next() unless @constructor._after?[method_name]?
    methods = @constructor._after[method_name].map (i) ->
      (cb) =>
        i.apply @, [cb].concat(Array::slice.call(args))
    async.series(methods, next)

  _apply_before: (method_name, args, next) ->
    return next() unless @constructor._before?[method_name]?
    methods = @constructor._before[method_name].map (i) =>
      (cb) =>
        i.apply @, [cb].concat(Array::slice.call(args))
    async.series(methods, next)

  _execute: (action) ->
    throw new Error "Could not find #{action} in #{@_name}" if not @[action]?
    @_action = action
    
    @_apply_before '_execute', [action], (err) =>
      return @error(err) if err?
      @[action].call(@, action)
  
  respond: -> @_responder.respond(arguments...)

  not_found: (err) ->
    @_responder.respond {
      code: 404
      content: if (typeof err is 'object' and Object::toString.call(err) is '[object Error]') then err else new Error(err)
    }
  
  unauthorized: (err) ->
    @_responder.respond {
      code: 401
      content: if (typeof err is 'object' and Object::toString.call(err) is '[object Error]') then err else new Error(err)
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
  
  respond_json: (code, obj) ->
    @set_headers('Content-Type': 'application/json')
    @respond(code: code, content: JSON.stringify(obj))
  
  respond_with: (promise_or_data, fields) ->
    is_error = (e) ->
      proto = e.__proto__
      while proto? and proto isnt Object.prototype
        return true if proto.toString() is Error.prototype.toString()
        proto = proto.__proto__
      false
    
    respond = (err, data) =>
      return @respond_json(500, {error: err.message}) if err?
      return @respond_json(404, 'Not Found') unless data?

      extract = (data, field) ->
        if Array.isArray(data)
          _(data).pluck(field)
        else
          _([data]).pluck(field)[0]

      only = (data, list) ->
        list = list.split(',') unless Array.isArray(list)
        if Array.isArray(data)
          data.map (d) -> _(d).pick(list)
        else
          _([data]).pluck(list)[0]

      except = (data, list) ->
        list = list.split(',') unless Array.isArray(list)
        if Array.isArray(data)
          data.map (d) -> _(d).omit(list)
        else
          _(data).omit(list)

      if fields?
        if typeof fields is 'function'
          data = fields(data)
        else if typeof fields is 'string' or Array.isArray(fields)
          data = only(data, fields)
        else
          data = only(data, fields.only) if fields.only?
          data = except(data, fields.except) if fields.except?
          data = extract(data, fields.extract) if fields.extract?

      @respond_json(200, data)

    return respond() unless promise_or_data?
    if promise_or_data.onAll? and typeof promise_or_data.onAll is 'function'
      promise_or_data.onAll(respond)
    else
      return respond(promise_or_data) if is_error(promise_or_data)
      respond(null, promise_or_data)
  
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
