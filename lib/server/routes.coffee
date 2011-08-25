path = require 'path'

module.exports = class Routes
  constructor: ->
    @routes = {}
    
  _childRoutes: (path, routes) ->
    child = new Routes()
    child.parent = @parent ? this
    child.prefix = (if @prefix? then @prefix + '/' else '') + path
    routes.call child
  
  match: (path, options) ->
    p = (if @prefix? then @prefix + '/' else '') + path
    p = (if p[0] is '/' then '' else '/') + p
    
    options = path unless options?
    if typeof options is 'string'
      a = method: 'get'
      [foo, a.controller, bar, a.action] = /^([^#]+)(#(.+))?$/.exec options
      a.action ?= 'index'
      options = a
    else
      options.method ?= 'get'
      options.action ?= 'index'
      options.controller ?= path
    options.path = p
    
    (@parent ? this).routes["#{options.method} #{p}"] = options

  scope: (path, routes) ->
    @_childRoutes path, routes
        
  resources: (path, routes) ->
    @match path,               method: 'get',     action: 'index',  controller: path
    @match "#{path}/new",      method: 'get',     action: 'new',    controller: path
    @match path,               method: 'post',    action: 'create', controller: path
    @match "#{path}/:id",      method: 'get',     action: 'show',   controller: path
    @match "#{path}/:id/edit", method: 'get',     action: 'edit',   controller: path
    @match "#{path}/:id",      method: 'put',     action: 'update', controller: path
    @match "#{path}/:id",      method: 'delete',  action: 'delete', controller: path
    
    if routes?
      @_childRoutes path, routes
      
Routes.create = (routesPath) ->
  routes = new Routes()
  if path.existsSync routesPath
    routesMethod = require routesPath
    routesMethod.call routes
  routes.routes