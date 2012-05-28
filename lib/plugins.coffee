_ = require 'underscore'
util = require './util'

class Plugins
  constructor: ->
    @plugins = []
    @plugins_by_name = {}
  
  load: ->
    @plugins_by_name = {}
    @plugins = (util.read_package()['caboose-plugins'] || []).map (plugin_name) =>
      plugin = require(plugin_name)['caboose-plugin']
      throw new Error("#{plugin_name} is not a caboose plugin") unless plugin?
      plugin.name = plugin_name
      @plugins_by_name[plugin_name] = plugin
      plugin
  
  initialize: ->
    for p in @plugins when p.initialize?
      p.initialize()
  
  config: ->
    _(@plugins).inject ((o, p) ->
      _(o).extend(p.config) if p.config?
      o
    ), {}
  
  is_loaded: (name) ->
    @plugins_by_name[name]?
  
  get: (name) ->
    @plugins_by_name[name]

module.exports = Plugins
