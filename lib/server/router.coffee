path = require 'path'
express = require 'express'
Route = require './route'

module.exports = class Router
  constructor: (@server) ->
    @server.use express.bodyParser()
    @server.use express.methodOverride()
    @server.use express.cookieParser()
    @server.use express.session secret: 'some kind of random string'
    @server.use @server.router

    @server.error = (err, req, res) ->
      console.error err.stack if err
      res.send {success: false, message: err.message}, 500
      
  add: (route) ->
    path = route.path
    path += '.:format?' unless path[path.length - 1] is '/'
    console.log "#{route.method} #{path}"
    @server[route.method] path, (req, res, next) ->
      route.respond req, res, next

Router.create = (server, routes) ->
  router = new Router server
  for k, spec of routes.routes
    route = Route.create spec
    router.add route if route?
  router