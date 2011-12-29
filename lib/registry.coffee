_ = require 'underscore'
ControllerFactory = require './controller/controller_factory'

cache = exports.cache = {}
registered_getters = exports.registered_getters = [{
  name: 'controller',
  get: (parsed_name) ->
    return null if parsed_name[parsed_name.length - 1] isnt 'controller'
    ControllerFactory.compile Caboose.path.controllers.join(parsed_name.join('_') + '.coffee').toString()
}, {
  name: 'helper',
  get: (parsed_name) ->
    return null if parsed_name[parsed_name.length - 1] isnt 'helper'
    Caboose.path.helpers.join(parsed_name.join('_')).require()
}]

split = exports.split = (name) ->
  start = 0
  parts = []
  type = 0
  
  push = (segment_type, start_increment) ->
    if type isnt segment_type
      parts.push name.substring(start, x).toLowerCase() unless start is x
      start = x + start_increment
    type = segment_type
  
  for x in [0...name.length]
    c = name[x]
    if not /[0-9a-zA-Z]/.test c
      push 1, 1
    else if /[0-9]/.test c
      push 2, 0
    else if c.toUpperCase() is c
      push 3, 0
    else
      type = 0
  parts.push name.substring(start, name.length).toLowerCase() unless start is name.length
  parts

exports.register = (name, getter) ->
  throw new Error("There is already a getter for #{name} in the registry") if _(registered_getters).find((g) -> g.name is name)
  getter.name = name
  registered_getters.push getter

exports.get = (name) ->
  parsed_name = split name
  return cache[parsed_name] if cache[parsed_name]?
  
  for getter in registered_getters
    obj = getter.get parsed_name
    if obj?
      cache[parsed_name] = obj
      return obj
  null

# path = require 'path'
# paths = require('./paths').get()
# Model = require './model/model'
# ViewFactory = require './view/view_factory'
# ControllerFactory = require './controller/controller_factory'
# 
# class Registry
#   constructor: ->
#     @factories = {}
# 
#   split: (name) ->
#     start = 0
#     parts = []
#     for x in [0...name.length]
#       c = name[x]
#       if not /[0-9a-zA-Z]/.test c
#         parts.push name.substring(start, x).toLowerCase() unless start is x
#         start = x + 1
#       else if c.toUpperCase() is c
#         parts.push name.substring(start, x).toLowerCase() unless start is x
#         start = x
#     parts.push name.substring(start, name.length).toLowerCase() unless start is name.length
#     parts
#     
#   split_view: (name) ->
#     parts = []
#     parts.push @split(part) for part in name.split '#'
#     parts
# 
#   get: (name) ->
#     parsed = @split name
#     key = parsed.join '_'
#     return @factories[key] if @factories[key]?
#     if @["get_#{parsed[parsed.length - 1]}"]?
#       type = parsed[parsed.length - 1]
#     else
#       type = 'model'
#     factory = @["get_#{type}"].call this, name, parsed
#     return null unless factory?
#     factory.type = type
#     @factories[key] = factory if factory?
#     factory
# 
#   get_controller: (name, parsed) ->
#     parsed = @split name unless parsed?
#     key = parsed.join '_'
#     ControllerFactory.compile path.join(paths.controllers, key + '.coffee')
#   
#   get_view: (name, parsed) ->
#     parsed = @split_view name
#     parsed[1].pop() if parsed[1]? and parsed[1][parsed[1].length - 1] is 'view'
#     controller = parsed[0].join '/'
#     action = parsed[1] ? 'index'
#     ViewFactory.compile path.join(paths.views, controller, "#{action}.html.ejs")
#   
#   get_model: (name, parsed) ->
#     parsed = @split name unless parsed?
#     key = parsed.join '_'
#     Model.compile path.join(paths.models, key + '.coffee')
# 
# global.registry = new Registry()
# module.exports = global.registry