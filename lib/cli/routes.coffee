exports.description = 'Display configured routes'

exports.method = ->
  Caboose.app.initialize ->
    r = []
    for k, route of Caboose.app.routes.routes
      r.push route
    cliff = require 'cliff'
    # console.log r
    console.log cliff.stringifyObjectRows(r, ['method', 'path', 'controller', 'action'])