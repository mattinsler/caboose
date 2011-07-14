fs = require 'fs'
path = require 'path'
express = require 'express'

module.exports = class Server
  constructor: (routeConfigurator) ->
    @server = express.createServer()
    @server.configure =>
      @server.use express.bodyParser()
      @server.use express.methodOverride()
      @server.use express.cookieParser()
      @server.use @server.router
    
    @router = new Router @server

    if routeConfigurator?
      if typeof routeConfigurator is 'string'
        @routeDirectory routeConfigurator
      else if Array.isArray routeConfigurator
        @routeDirectory dir for dir in routeConfigurator
      else if typeof routeConfigurator is 'object'
        @route routeConfigurator

  route: (configurator) ->
    configurator @router

  routeDirectory: (dirPath) ->
    @route (router) ->
      fs.readdirSync(dirPath).forEach (file) ->
         route = {}
         route[/^([^.]+)/.exec(file)[1]] = require path.join(dirPath, file)
         router.resources route

  listen: (port) ->
    @server.listen port
    this

  address: ->
    @server.address()