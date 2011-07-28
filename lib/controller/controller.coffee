module.exports = class Controller
  execute: (action) ->
    x = 0
    next = (err) =>
      return @error err if err?
      return this[action].call this if x is @filters.length
      filter = @filters[x++]
      return next() if filter.only? and action in filter.only
      if typeof filter.method is 'string'
        this[filter.method].call this, next
      else if typeof filter.method is 'function'
        filter.method.call this, next
    next()

  error: (err) ->
    @responder.next err
  render: (data) ->
    @responder.render (data ? this)
  redirect_to: (url) ->
    @responder.redirect_to url