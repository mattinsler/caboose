_ = require 'underscore'
async = require 'async'
Controller = require './controller'

build = ->
  __constructor__ = @_actions.constructor
  rx = new RegExp("^\\s*function\\s+#{@name}\\s*\\(\\)\\s*{\\s*#{@name}\\.__super__\\.constructor\\.apply\\(this,\\s*arguments\\);\\s*}\\s*$")
  
  base_controller = (if @extends? then Caboose.registry.get(@extends) else null) || Controller
  
  # Default constructor
  if rx.test(__constructor__.toString().replace(/[ \t\r\n]+/g,' '))
    controller = class extends base_controller
  else
    controller = class extends base_controller
      constructor: __constructor__
  
  controller.after = Controller.after
  controller.before = Controller.before
  
  # private properties
  controller["_#{prop}"] = @[prop] for prop in ['name', 'short_name', 'extends']
  
  Builder.plugins[x].build?.call(@, controller) for x in [Builder.plugins.length - 1..0]
  
  controller::_name = @name
  controller::_short_name = @short_name
  controller::_extends = @extends
  Object.defineProperty(controller::, 'request', {enumerable: true, get: -> @_responder.req})
  Object.defineProperty(controller::, 'response', {enumerable: true, get: -> @_responder.res})
  Object.defineProperty(controller::, 'cookies', {enumerable: true, get: -> if @_responder.req.cookies? then @_responder.req.cookies else null})
  Object.defineProperty(controller::, 'session', {enumerable: true, get: -> if @_responder.req.session? then @_responder.req.session else null})
  Object.defineProperty(controller::, 'body', {enumerable: true, get: -> if @_responder.req.body? then @_responder.req.body else null})
  Object.defineProperty(controller::, 'params', {enumerable: true, get: -> if @_responder.req.params? then @_responder.req.params else null})
  Object.defineProperty(controller::, 'query', {enumerable: true, get: -> if @_responder.req.query? then @_responder.req.query else null})
  Object.defineProperty(controller::, 'headers', {enumerable: true, get: -> if @_responder.req.headers? then @_responder.req.headers else null})

  controller

class Builder
  @config: {}
  @plugins: []
  
  @add_plugin: (config_namespace, opts) ->
    if opts.name?
      for plugin in @plugins
        throw new Error("[Plugin #{opts.name}] another caboose controller plugin already exists with the same name") if opts.name is plugin.name
    if opts.config?
      throw new Error("[Plugin #{opts.name}] another caboose controller plugin is already using the same config namespace") if @config[config_namespace]?
      @config[config_namespace] = opts.config
    @plugins.push opts
  
  constructor: (@name, @extends) ->
    Object.defineProperty @, 'name', {enumerable: false}
    Object.defineProperty @, 'extends', {enumerable: false}
    Object.defineProperty @, 'short_name', {value: Caboose.registry.split(@name).slice(0, -1).join('_'), enumerable: false}
    
    plugin.initialize?.apply(this) for plugin in Builder.plugins
    
    Object.defineProperty @, 'build', {value: build, enumerable: false}
    
    for plugin in Builder.plugins
      do (plugin) =>
        if plugin.name? and plugin.execute?
          @[plugin.name] = ->
            plugin.execute.apply(this, arguments)
            this

create_filter_object = (filter, options) ->
  options = filter if !options? and typeof filter is 'object'
  options = {only: null, except: null} unless options?
  options.only = if options.only? then (if options.only instanceof Array then options.only else [options.only]) else null
  options.except = if options.except? then (if options.except instanceof Array then options.except else [options.except]) else null
  options.method ?= filter
  throw new Error('Filters must specify a method') unless options.method?
  throw new Error('Filters can have either an only or except option') if options.only? and options.except?
  options

construct_inherited_list = (controller, name) ->
  # c = controller
  # controller::[name] = @[name]
  # until c._extends is 'Controller'
  #   c = Caboose.registry.get(c._extends)
  #   controller::[name].splice(0, 0, c::[name]...)
  list = @[name].slice()
  c = controller
  while c?
    list.splice(0, 0, c::[name]...) if c::[name]?
    c = if c.__super__? then c.__super__.constructor else null
  list

filters_for = (context, filter_list, action) ->
  filter_list.filter((filter) ->
    if filter.only?
      return action in filter.only
    else if filter.except?
      return action not in filter.except
    true
  ).map (filter) ->
    if typeof filter.method is 'string'
      throw new Error("Filter #{filter.method} does not exist") unless context[filter.method]?
      return context[filter.method]
    else if typeof filter.method is 'function'
      return filter.method
    throw new Error('Filter is neither a method or name of a method')

Builder.add_plugin 'csrf',
  config:
    enabled: true
    passive_aggressive: true
    value: (request) ->
      request.body?._csrf || request.query?._csrf || request.headers['x-csrf-token']
  
  build: (controller) ->
    generate_token = ->
      require('crypto').randomBytes(Math.ceil(24 * 3 / 4)).toString('base64').slice(0, 24)

    # add csrf if configured
    unless Caboose.app.config.controller.csrf.enabled is false
      controller.before '_execute', (next) ->
        token = @session._csrf ||= generate_token()
        return next() if @request.method in ['GET', 'HEAD', 'OPTIONS']
        value = Caboose.app.config.controller.csrf.value(@request)
        if value isnt token
          return next(new Error('Unauthorized')) unless Caboose.app.config.controller.csrf.passive_aggressive
          console.log 'WARNING: CSRF protection is not being enforced!\n         Consider using form_for in your views or adding csrf_tag() to your forms and\n         turning off config.controller.csrf.passive_aggressive.'
        next()

Builder.add_plugin 'action',
  name: 'action'
  initialize: -> Object.defineProperty @, '_actions', {value: {}, enumerable: false}
  execute: (name, method) -> @_actions[name] = method
  build: (controller) -> controller::[k] = v for k, v of @_actions when k isnt 'constructor'

Builder.add_plugin 'before_action',
  name: 'before_action'
  initialize: -> Object.defineProperty @, '_before_actions', {value: [], enumerable: false}
  execute: (filter, options) -> @_before_actions.push(create_filter_object(filter, options))
  build: (controller) ->
    controller::_before_actions = @_before_actions
    controller.before '_execute', (next, action) ->
      funcs = []
      c = controller
      while c?
        funcs.splice(0, 0, c::_before_actions...) if c::_before_actions?
        c = if c.__super__? then c.__super__.constructor else null

      try
        filters = filters_for(@, funcs, action)
      catch e
        next(e)

      async.series(filters.map((i) => (cb) => i.call(@, cb, action)), next)

#   name: 'after_action'
#   initialize: -> Object.defineProperty @, '_after_actions', {value: [], enumerable: false}
#   execute: (filter, options) -> @_after_actions.push(create_filter_object(filter, options))
#   build: (controller) -> construct_inherited_list.call(@, controller, '_after_actions')

Builder.add_plugin 'helper',
  name: 'helper'
  initialize: -> Object.defineProperty @, '_helpers', {value: [], enumerable: false}
  execute: (helper) -> @_helpers.push(helper)
  build: (controller) ->
    helpers = @_helpers
    helpers.push(controller.__super__._helpers) if controller.__super__?._helpers?
    controller::_helpers = _.extend.bind(null, {}).apply(null, helpers)

module.exports = Builder
