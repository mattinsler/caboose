Compiler = require '../compiler'
Controller = require './controller'
ControllerFactory = require './controller_factory'

module.exports = class ControllerFactoryCompiler extends Compiler
  constructor: (@registry) ->
    
  _init: ->
    @filters = []

  precompile: ->
    @_init()
    
    @name = /class\W+([^\W]+)\W+extends\W+[^\+]*Controller/.exec(@code)[1]
    throw new Error 'Could not find a controller defined' if not @name?

    @code = @code.replace new RegExp("class\\W+#{@name}"), "this.class = class #{@name}"
    
    while importCall = /import\W+('([^']+)'|"([^"]+)")/.exec @code
      importObject = @registry.get importCall[2]
      importObject = importObject.class if importObject.type is 'controller'
      @scope[importCall[2]] = importObject
      @code = @code.replace importCall[0], ''

    @scope.Controller = Controller
    @scope.before_filter = (filter) =>
      if typeof filter is 'string'
        @filters.push method: filter, only: null
      else if typeof filter is 'object' and typeof filter.filter? is 'string'
        @filters.push method: filter.filter, only: filter.only
  
  respond: ->
    new ControllerFactory @scope.class, @filters