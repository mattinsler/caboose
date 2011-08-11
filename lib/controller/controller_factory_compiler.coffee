Compiler = require '../compiler'
Controller = require './controller'
ControllerFactory = require './controller_factory'

class ControllerFactoryCompiler extends Compiler
  constructor: -> super()
  
  precompile: ->
    @filters = []
    
    matches = /class\W+([^\W]+)\W+extends\W+([^\W]*Controller)/.exec(@code)
    throw new Error 'Could not find a controller defined' unless matches?
    @name = matches[1]
    @extends = matches[2]

    @code = @code.replace new RegExp("class\\W+#{@name}"), "this.class = class #{@name}"
    
    @scope.Controller = Controller
    @scope.before_filter = (filter) =>
      if typeof filter in ['string', 'function']
        @filters.push method: filter, only: null
      else if typeof filter is 'object' and typeof filter.filter? is 'string'
        @filters.push method: filter.filter, only: filter.only
        
    @apply_scope_plugins 'controllers'
    @apply_precompile_plugins 'controllers'

  postcompile: ->
    @apply_postcompile_plugins 'controllers'
  
  respond: ->
    @response = new ControllerFactory @name, @extends, @scope.class, @filters
    @apply_respond_plugins 'controllers'
    @response
    
module.exports = ControllerFactoryCompiler