Responder = require('caboose').controller.Responder
Promise = require('caboose-model').Promise

_render = Responder::render
Responder::render = (controller, data, options) ->
  obj = data || controller
  
  promises = Object.keys(obj).filter (k) -> obj[k] instanceof Promise
  return _render.call(@, controller, data, options) if promises.length is 0
  
  count = 0
  done = =>
    return _render.call(@, controller, data, options) if ++count is promises.length
  
  for k in promises
    do (k) ->
      obj[k].on 'complete', (val) ->
        obj[k] = val
        done()
