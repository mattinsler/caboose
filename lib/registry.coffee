path = require 'path'
Model = require './model'
ControllerFactory = require './controller/controller_factory'

cache = {}

split = (name) ->
  start = 0
  parts = []
  for x in [0...name.length]
    c = name[x]
    if not /[0-9a-zA-Z]/.test c
      parts.push name.substring(start, x).toLowerCase() unless start is x
      start = x + 1
    else if c.toUpperCase() is c
      parts.push name.substring(start, x).toLowerCase() unless start is x
      start = x
  parts.push name.substring(start, name.length).toLowerCase() unless start is name.length
  parts

exports.get = (name) ->
  if not cache[name]?
    if /Controller$/.test(name)
      parsed = split name
      cache[name] = ControllerFactory.compile path.join(Caboose.path.controllers, parsed.join('_') + '.coffee')
    else
      parsed = split name
      cache[name] = Model.model parsed.join('_')
  cache[name]


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