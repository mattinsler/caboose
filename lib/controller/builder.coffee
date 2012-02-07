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
  @add_plugin: (opts) ->
    if opts.name?
      for plugin in @plugins
        throw new Error("[Plugin #{opts.name}] another caboose controller plugin already exists with the same name") if opts.name is plugin.name
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
  options.only ?= null
  options.except ?= null
  options.method ?= filter
  throw new Error('Filters must specify a method') unless options.method?
  throw new Error('Filters can have either an only or except option') if options.only? and options.except?
  options

construct_inherited_list = (controller, name) ->
  c = controller
  controller::[name] = @[name]
  until c._extends is 'Controller'
    c = Caboose.registry.get(c._extends)
    controller::[name].unshift.apply(controller::[name], c::[name])

Builder.plugins = [{
  name: 'action'
  initialize: -> Object.defineProperty @, '_actions', {value: {}, enumerable: false}
  execute: (name, method) -> @_actions[name] = method
  build: (controller) -> controller::[k] = v for k, v of @_actions when k isnt 'constructor'
}, {
  name: 'before_filter'
  initialize: -> Object.defineProperty @, '_before_filters', {value: [], enumerable: false}
  execute: (filter, options) -> @_before_filters.push(create_filter_object(filter, options))
  build: (controller) -> construct_inherited_list.call(@, controller, '_before_filters')
}, {
  name: 'after_filter'
  initialize: -> Object.defineProperty @, '_after_filters', {value: [], enumerable: false}
  execute: (filter, options) -> @_after_filters.push(create_filter_object(filter, options))
  build: (controller) -> construct_inherited_list.call(@, controller, '_after_filters')
}, {
  name: 'around_filter'
  initialize: -> Object.defineProperty @, '_around_filters', {value: [], enumerable: false}
  execute: (filter, options) -> @_around_filters.push(create_filter_object(filter, options))
  build: (controller) -> construct_inherited_list.call(@, controller, '_around_filters')
}, {
  name: 'helper'
  initialize: -> Object.defineProperty @, '_helpers', {value: [], enumerable: false}
  execute: (helper) -> @_helpers.push(helper)
  build: (controller) ->
    construct_inherited_list.call(@, controller, '_helpers')
    controller::_helpers.unshift(require('./helpers/view_helper')) if controller._extends is 'Controller'
}]

module.exports = Builder
