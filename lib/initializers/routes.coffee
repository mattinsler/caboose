path = require 'path'
Routes = require '../server/routes'

module.exports = (next) ->
  Caboose.app.routes = Routes.create path.join(Caboose.root, 'config', 'routes.coffee')  
  next()