SpecCompiler = require './spec_compiler'
Model = require './model'

class ModelCompiler extends SpecCompiler
  constructor: -> super()
  
  precompile: ->
    @name = /class\W+([^\W]+)\W+extends\W+Model/.exec(@code)[1]
    throw new Error 'Could not find a model defined' if not @name?
    super()
  
  respond: ->
    super()
    spec = @response
    @response = new Model @name, @collection_name ? @name, spec
    @apply_respond_plugins 'models'
    @response
    
module.exports = ModelCompiler