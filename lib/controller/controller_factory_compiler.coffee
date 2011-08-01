Compiler = require '../compiler'
Controller = require './controller'
ControllerFactory = require './controller_factory'
Plugins = require '../plugins'

plugins = Plugins.get 'controllers', 'compiler'

module.exports = class ControllerFactoryCompiler extends Compiler
  precompile: ->
    @filters = []
    
    matches = /class\W+([^\W]+)\W+extends\W+([^\W]*Controller)/.exec(@code)
    throw new Error 'Could not find a controller defined' unless matches?
    @name = matches[1]
    @extends = matches[2]

    @code = @code.replace new RegExp("class\\W+#{@name}"), "this.class = class #{@name}"
    
    @scope.Controller = Controller
    @scope.before_filter = (filter) =>
      if typeof filter is 'string'
        @filters.push method: filter, only: null
      else if typeof filter is 'object' and typeof filter.filter? is 'string'
        @filters.push method: filter.filter, only: filter.only
        
    add_to_scope = (k, v) =>
      @scope[k] = =>
        v.apply this, arguments

    if plugins.scope?
      for plugin in plugins.scope
        add_to_scope k, v for k, v of plugin
        
    if plugins.precompile?
      plugin.call this for plugin in plugins.precompile
  
  postcompile: ->
    if plugins.postcompile?
      plugin.call this for plugin in plugins.postcompile
  
  respond: ->
    @response = new ControllerFactory @name, @extends, @scope.class, @filters
    if plugins.respond?
      plugin.call this for plugin in plugins.respond
    @response