path = require 'path'
express = require 'express'
Route = require './route'
paths = require('../paths').get()

module.exports = class Router
  constructor: (@server) ->
    # @server.error = (err, req, res) ->
    #   console.error err.stack if err
    #   res.send {success: false, message: err.message}, 500
      
  add: (route) ->
    path = route.path
    path += '.:format?' unless path[path.length - 1] is '/'
    console.log "#{route.method} #{path} (#{route.controllerFactory.filters.length} filter(s) on controller)"
    @server[route.method] path, (req, res, next) ->
      route.respond req, res, next

Router.create = (server, routes) ->
  router = new Router server
  for k, spec of routes.routes
    route = Route.create spec
    router.add route if route?
  router