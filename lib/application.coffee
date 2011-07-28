path = require 'path'
express = require 'express'
Routes = require './server/routes'
Router = require './server/router'
Registry = require './registry'

module.exports = class Application
  constructor: ->
    @registry = new Registry()
    
  initialize: (config) ->
    @config = config
    @http = express.createServer() if config.http
    
    @routes = Routes.create path.join(@paths.config, 'routes.coffee')
    @router = Router.create @http, @routes
    
  listen: ->
    @http.listen @config.http.port
    
  address: ->
    @http.address()