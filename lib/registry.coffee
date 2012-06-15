_ = require 'underscore'
ControllerCompiler = require './controller/controller_compiler'

cache = exports.cache = {}
registered_getters = exports.registered_getters = []

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
  return cache[parsed_name].object if cache[parsed_name]?
  
  _find = (parsed_name) ->
    for getter in registered_getters
      o = getter.get(parsed_name)
      return o if o?
    null

  o = _find(parsed_name)
  return null unless o?

  # filename = o.file.toString()
  # console.log "watching #{parsed_name} -> #{filename}"
  # require('fs').watch filename, {persistent: false}, (event) ->
  #   console.log "#{event} #{parsed_name}"
  #   try
  #     new_o = _find(parsed_name)
  #     cache[parsed_name].object = new_o.object
  #   catch e
  #     console.error "ERROR: Reverting to old version of #{parsed_name}"
  #     console.error e.stack
  cache[parsed_name] = o
  return o.object



exports.register 'controller', {
  get: (parsed_name) ->
    return null if parsed_name[parsed_name.length - 1] isnt 'controller'
    name = parsed_name.join('_')
    try
      files = Caboose.path.controllers.readdir_sync()
      controller_file = files.filter((f) -> f.basename is name)
      controller_file = if controller_file.length > 0 then controller_file[0] else null
      return null unless controller_file?
      return {file: controller_file, object: ControllerCompiler.compile(controller_file)} if controller_file.extension is 'coffee'
      {file: controller_file, object: controller_file.require()}
    catch e
      console.error e.stack
}

exports.register 'helper', {
  get: (parsed_name) ->
    return null if parsed_name[parsed_name.length - 1] isnt 'helper'
    try
      file = Caboose.path.helpers.join(parsed_name.join('_'))
      {file: file, object: file.require()}
    catch e
      console.error e.stack
}
