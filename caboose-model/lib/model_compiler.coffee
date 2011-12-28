caboose = require 'caboose'
Path = caboose.path
Compiler = caboose.internal.compiler
Builder = require './builder'
# 
# Model = require 'caboose-model'
# 
# User = Model.create('User')
#             .store_in('user')
#             .authenticate_using('email', 'password')
#             .authenticate_with_token('auth_token')
# 
# User.static 'find_by_email', (email) ->
#   @where {email: email}
# 
# User.instance 'full_name', ->
#   "#{@first_name} #{@last_name}"
# 
# module.exports = User.build()

# // class User extends Model
# //   store_in 'user'
# //   
# //   authenticate_using 'email', 'password'
# //   authenticate_with_token 'auth_token'
# //   
# //   static 'find_by_email', (email) ->
# //     @where {email: email}
# //   
# //   instance 'full_name', ->
# //     "#{@first_name} #{last_name}"



class ModelCompiler extends Compiler
  precompile: ->
    matches = /class\W+([^\W]+)\W+extends\W+([^\W]*Model)/.exec(@code)
    throw new Error 'Could not find a model defined' unless matches?
    @name = matches[1]
    # @extends = matches[2]
    
    @builder = new Builder(@name)
    
    @scope.Model = class __MODEL__
    for k of @builder
      do (k) =>
        @scope[k] = (args...) =>
          @builder[k](args...)

    # @apply_scope_plugins 'models'
    # @apply_precompile_plugins 'models'

  postcompile: ->
    # @apply_postcompile_plugins 'models'
  
  respond: ->
    @response = @builder.build()
    
    # short_name = /\/([^\/.]+)\_controller.coffee$/.exec(@fullPath)[1]
    
    # @response = new ControllerFactory @name, short_name, @extends, @scope.class, @filters, @helpers
    # @apply_respond_plugins 'models'
    @response

  @compile = (file) ->
    file = new Path(file) unless file instanceof Path
    return null unless file.exists_sync()
    compiler = new ModelCompiler()
    try
      compiler.compile_file file.path
    catch err
      console.log "Error trying to compile Model for #{file.path}"
      console.error err.stack
      null
    
module.exports = ModelCompiler
