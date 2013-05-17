_ = require 'underscore'
URL = require 'url'
Route = require './route'
Path = require '../path'

conditions = {
  domain: (req, condition) ->
    return condition(req.parsed.domain, req) if typeof condition is 'function'
    req.parsed.domain is condition
  subdomain: (req, condition) ->
    return condition(req.parsed.subdomain, req) if typeof condition is 'function'
    req.parsed.subdomain is condition
}

class MatchedRoute
  constructor: (@node, @params) ->

  match_segment: (segment, req) ->
    return new MatchedRoute(@node.segments[segment], @params) if @node.segments[segment]?
    routes = []
    for param_node in @node.params
      if param_node.satisfies_condition(segment, req)
        params = _.extend(@params)
        params[param_node.segment] = segment
        routes.push(new MatchedRoute(param_node, params))
    routes

class MatchingRoutes
  constructor: (root, @req) ->
    @routes = [new MatchedRoute(root, {})]

  next_segment: (segment) ->
    next_routes = []
    for route in @routes
      next_routes = next_routes.concat(route.match_segment(segment, @req))
    @routes = next_routes
    
    return @routes.length > 0
  
  route: (method) ->
    return null unless @routes.length > 0
    
    routes = _(@routes).reject (r) -> !r.node.methods[method]?
    return null if routes.length is 0
    
    find_matching_route = =>
      for matched_route in routes
        r = _(matched_route.node.methods[method]).find (r) =>
          return true unless r.conditions?
          for type, condition of r.conditions
            unless type[0] is ':'
              throw new Error('Unknown condition type: ' + type) unless module.exports.conditions[type]?
              return false unless module.exports.conditions[type](@req, condition)
          true
        return [matched_route, r.route] if r?
      [null, null]
    
    [matched_route, route] = find_matching_route()
    return null unless route?
    
    _.extend(@req.params, matched_route.params)
    route

class Node
  constructor: (@segment, options) ->
    @segments = {}
    @params = []
    @methods = {}
    @conditions = options.conditions if options?.conditions?
  path: ->
    @segment

class ParamNode extends Node
  @create_matcher: (condition) ->
    return ((segment) -> true) unless condition?
    return ((segment) -> segment is condition) if typeof condition is 'string'
    return ((segment) -> condition.test(segment)) if (typeof condition is 'object' and Object::toString.call(condition) is '[object RegExp]')
    return ((segment) -> segment in condition) if Array.isArray(condition)
    return ((segment, req) -> condition(segment, req)) if typeof condition is 'function'
  
  constructor: (segment, options) ->
    super
    condition = options.conditions[":#{segment}"] if options.conditions?[":#{segment}"]?
    @matcher = ParamNode.create_matcher(condition)

  satisfies_condition: (segment, req) ->
    @matcher(segment, req)

class Configurator
  constructor: (@root, @options) ->

  route: (path, opts) ->
    if typeof opts is 'string'
      options = _(arguments[2] || {}).clone()
      [nothing, options.controller, nothing, options.action] = /^([^#]+)(#(.+))?$/.exec(opts)
    else
      options = _(opts).clone()
    [nothing, nothing, options.method, path] = /^(([^ ]+) +)?([^ ]+)$/.exec(path)

    options.method = (options.method || 'get').toUpperCase()
    options.action ?= 'index'
    options.controller ?= path
    _(options).extend(@options) if @options?
    
    node = @root
    path_segments = ((@options?.base_path || '') + "/#{path}").split('/').filter((s) -> s isnt '')

    for segment in path_segments
      if segment[0] is ':'
        param = segment.substr(1)
        new_node = new ParamNode(param, options)
        node.params.push(new_node)
        node = new_node
      else
        node.segments[segment] = new Node(segment, options) unless node.segments[segment]?
        node = node.segments[segment]
    
    conditions = options.conditions
    delete options.conditions
    
    node.methods = {} unless node.methods?
    node.methods[options.method] = [] unless node.methods[options.method]?
    node.methods[options.method].push {route: new Route(options), conditions: conditions}
  
  # @resources 'foo', ->
  # @resources 'foo', 'api_foo', ->
  # @resources 'foo', {foo: 'bar'}, ->
  # @resources 'foo', 'api_foo', {foo: 'bar'}, ->
  resources: (path, controller, opts, routing_method) ->
    if typeof controller is 'function'
      routing_method = controller
      controller = path
      opts = {}
    if typeof opts is 'function'
      routing_method = opts
      opts = {}
    if typeof controller isnt 'string'
      opts = controller or {}
      controller = opts.controller or path
    opts ?= {}
    
    path = path.replace(/(^\/+|\/+$)/g, '')
    id_field = opts.rename_id_to ? 'id'
    child_id_field = opts.rename_id_to ? "#{path}_id"
    
    route_opts = _(opts).omit('method', 'action', 'controller', 'rename_id_to')
    
    @route path, "#{controller}#index", route_opts
    @route "#{path}/new", "#{controller}#new", route_opts
    @route "post #{path}", "#{controller}#create", route_opts
    @route "#{path}/:#{id_field}", "#{controller}#show", route_opts
    @route "#{path}/:#{id_field}/edit", "#{controller}#edit", route_opts
    @route "put #{path}/:#{id_field}", "#{controller}#update", route_opts
    @route "delete #{path}/:#{id_field}", "#{controller}#destroy", route_opts

    if routing_method?
      options = _.extend({}, @options, opts, {base_path: (@options?.base_path || '') + "/#{path}/:#{child_id_field}"})
      routing_method.call(new Configurator(@root, options))
    
  namespace: (path, routing_method) ->
    options = _.extend({}, @options, {base_path: (@options?.base_path || '') + "/#{path}"})
    routing_method.call(new Configurator(@root, options))
  
  domain: (domain, routing_method) ->
    throw new Error('Cannot have more than one domain condition in a route') if @options?.conditions?.domain?

    options = _.extend({}, @options, {conditions: {domain: domain}})
    routing_method.call(new Configurator(@root, options))

  subdomain: (subdomain, routing_method) ->
    throw new Error('Cannot have more than one subdomain condition in a route') if @options?.conditions?.subdomain?

    options = _.extend({}, @options, {conditions: {subdomain: subdomain}})
    routing_method.call(new Configurator(@root, options))

module.exports = class Router
  @conditions: conditions
  
  constructor: ->
    @root = new Node()

  parse: (routing_method) ->
    routing_method.call(new Configurator(@root))

  route: (req, res, next) ->
    try
      req.parsed = URL.parse("http://#{req.headers.host}#{req.url}", true)
      Object.defineProperty req, 'path', {value: new Path(req.path)}
      domains = req.parsed.hostname.split('.')
      x = if domains.slice(-1)[0] is 'localhost' then -1 else -2
      req.parsed.domain = domains.slice(x).join('.')
      req.parsed.subdomain = domains.slice(0, x).join('.')
      req.params = {} unless req.params?

      matching = new MatchingRoutes(@root, req)
      segments = req.parsed.pathname.split('/').filter((s) -> s isnt '')
      last = segments[segments.length - 1]
      segments[segments.length - 1] = last.split('.')[0] if last?
      for segment in segments
        return next() unless matching.next_segment(segment)
    
      route = matching.route(req.method)
      return next() unless route?

      req.params.format = last.split('.')[1..].join('.') if last?.split('.')[1..].length > 0
      
      route.respond(req, res, next)
    catch e
      console.error(e.stack) if e?
