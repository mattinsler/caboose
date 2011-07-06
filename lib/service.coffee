fs = require 'fs'
path = require 'path'
express = require 'express'

class Router
  constructor: (@server) ->

  resources: (config) =>
    _wrapFilter = (filter) ->
      (req, res, next) ->
        try
          filter req, next
        catch err
          next err
    _handle = (method, before, route, handler, action) =>
      filters = []
      for filter in (before || [])
        if typeof filter is 'function'
          filters.push _wrapFilter(filter)
        else if filter.filter? and typeof filter.filter is 'function'
          if not filter.only? or action in filter.only
            filters.push _wrapFilter(filter.filter)
      
      console.log "  #{route} -> #{action} #{filters.length}"
      @server[method] route, filters, (req, res) ->
        res.contentType 'application/json'
        handler[action] req, (err, data) ->
          if err
            console.error err.stack if err
            res.send err.stack, 500
          else
            res.send data, 200
    
    for name, handler of config
      console.log name
      before = handler.before
      for action of handler
        switch action
          when 'index'  then _handle 'get',    before, "/#{name}",          handler, action
          when 'new'    then _handle 'get',    before, "/#{name}/new",      handler, action
          when 'create' then _handle 'post',   before, "/#{name}",          handler, action
          when 'show'   then _handle 'get',    before, "/#{name}/:id",      handler, action
          when 'edit'   then _handle 'get',    before, "/#{name}/:id/edit", handler, action
          when 'update' then _handle 'put',    before, "/#{name}/:id",      handler, action
          when 'delete' then _handle 'delete', before, "/#{name}/:id",      handler, action

class Server
  constructor: (routeConfigurator) ->
    @server = express.createServer()
    @server.configure =>
      @server.use express.bodyParser()
      @server.use express.methodOverride()
      @server.use express.cookieParser()
      @server.use @server.router
    @server.configure 'development', =>
      @server.use express.errorHandler(dumpExceptions: true, showStack: true)
    @server.configure 'production', =>
      @server.use express.errorHandler()
    
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

exports.createServer = (routes) ->
  new Server routes