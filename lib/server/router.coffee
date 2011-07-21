path = require 'path'
Route = require './route'

module.exports = class Router
  constructor: (@app, @server) ->
    @server.error (err, req, res) ->
      console.error err.stack if err
      res.send {success: false, message: err.message}, 500

  # resources: (config) ->
  #   _wrapFilter = (filter) ->
  #     (req, res, next) ->
  #       try
  #         filter req, next
  #       catch err
  #         next err
  #   _handle = (method, before, route, handler, action) =>
  #     filters = []
  #     for filter in (before || [])
  #       if typeof filter is 'function'
  #         filters.push _wrapFilter(filter)
  #       else if filter?.filter? and typeof filter?.filter is 'function'
  #         if not filter.only? or action in filter.only
  #           filters.push _wrapFilter(filter.filter)
  #     
  #     console.log "  #{route} -> #{action} #{filters.length}"
  #     @server[method] route, filters, (req, res, next) ->
  #       res.contentType 'application/json'
  #       try
  #         handler[action] req, (err, data) ->
  #           return next err if err?
  #           res.send {success: true, data: data}, 200
  #       catch err
  #         next err
  #   
  #   for name, handler of config
  #     console.log name
  #     before = handler.before
  #     for action of handler
  #       switch action
  #         when 'index'  then _handle 'get',    before, "/#{name}",          handler, action
  #         when 'new'    then _handle 'get',    before, "/#{name}/new",      handler, action
  #         when 'create' then _handle 'post',   before, "/#{name}",          handler, action
  #         when 'show'   then _handle 'get',    before, "/#{name}/:id",      handler, action
  #         when 'edit'   then _handle 'get',    before, "/#{name}/:id/edit", handler, action
  #         when 'update' then _handle 'put',    before, "/#{name}/:id",      handler, action
  #         when 'delete' then _handle 'delete', before, "/#{name}/:id",      handler, action
          
          
Router.create = (app, server, routes) ->
  router = new Router app, server
  Route.addToRouter router, route for k, route of routes.routes
  router