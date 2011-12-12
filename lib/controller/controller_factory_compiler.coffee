Compiler = require '../compiler'
Controller = require './controller'
ControllerFactory = require './controller_factory'

ViewHelper = require './helpers/view_helper'

class ControllerFactoryCompiler extends Compiler
  constructor: -> super()
  
  precompile: ->
    @filters = []
    @helpers = [ViewHelper]
    
    matches = /class\W+([^\W]+)\W+extends\W+([^\W]*Controller)/.exec(@code)
    throw new Error 'Could not find a controller defined' unless matches?
    @name = matches[1]
    @extends = matches[2]

    @code = @code.replace new RegExp("class\\W+#{@name}"), "this.class = class #{@name}"
    
    @scope.Controller = Controller
    @scope.before_filter = (filter, options) =>
      if options?
        options.method = filter
        filter = options
      if typeof filter in ['string', 'function']
        @filters.push method: filter, only: null
      else if typeof filter is 'object' and filter.method? and typeof filter.method in ['string', 'function']
        @filters.push method: filter.method, only: filter.only
    
    @scope.helper = (helper) =>
      @helpers.push helper
        
    @apply_scope_plugins 'controllers'
    @apply_precompile_plugins 'controllers'

  postcompile: ->
    @apply_postcompile_plugins 'controllers'
  
  respond: ->
    short_name = /\/([^\/.]+)\_controller.coffee$/.exec(@fullPath)[1]
    
    @response = new ControllerFactory @name, short_name, @extends, @scope.class, @filters, @helpers
    @apply_respond_plugins 'controllers'
    @response
    
module.exports = ControllerFactoryCompiler
