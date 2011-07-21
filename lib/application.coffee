path = require 'path'
express = require 'express'
Routes = require './server/routes'
Router = require './server/router'

module.exports = class Application
  initialize: (config) ->
    @config = config
    @http = express.createServer() if config.http
    
    @routes = Routes.create path.join(@paths.config, 'routes.coffee')
    @router = Router.create this, @http, @routes
    
  listen: ->
    @http.listen @config.http.port