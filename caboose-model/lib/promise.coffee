class Promise
  constructor: (callback) ->
    @_emitted = {}
    @_emitter = new (require('events').EventEmitter)()
    @onAll(callback) if callback? and typeof callback is 'function'
  
  on: (event, callback) ->
    if @_emitted[event]
    then callback.apply(@, @_emitted[event])
    else @_emitter.on(event, callback)
    @
  
  onAll: (callback) ->
    @on('err', (err) =>
      callback.call(@, err)
    )
    @on('complete', (args...) =>
      callback.apply(@, [null].concat(args))
    )
    @

  _emit: (event, args...) ->
    return @ if @_emitted[event]?
    @_emitted[event] = args
    @_emitter.emit(event, args...)
    @

  complete: (args...) ->
    @_emit('complete', args...)
    @
  
  error: (args...) ->
    @_emit('err', args...)
    @
  
  callback: (err, args...) ->
    return @error(err) if err?
    @complete(args...)
  
module.exports = Promise
