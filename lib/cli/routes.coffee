exports.description = 'Display configured routes'

exports.method = ->
  Caboose.app.initialize ->
    r = (route for k, route of Caboose.app.routes)
    console.log require('cliff').stringifyObjectRows(r, ['method', 'path', 'controller', 'action'])