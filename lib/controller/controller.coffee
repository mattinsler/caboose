class Controller
  execute: (action) ->
    throw new Error "Could not find #{action} in #{@_name}" if not this[action]?
    
    x = 0
    next = (err) =>
      return @error err if err?
      return this[action].call this if x is @_filters.length
      filter = @_filters[x++]
      return next() if filter.only? and action in filter.only
      if typeof filter.method is 'string'
        this[filter.method].call this, next
      else if typeof filter.method is 'function'
        filter.method.call this, next
    next()

  error: (err) ->
    @_responder.next err
  render: (data) ->
    @_responder.render (data ? this)
  redirect_to: (url) ->
    @_responder.redirect_to url
    
  # options: httpOnly, secure, expires, maxAge
  set_cookie: (name, value, options) ->
    @_responder.res.cookie name, value, options
    
  clear_cookie: (name) ->
    @_responder.res.clearCookie name
    
module.exports = Controller