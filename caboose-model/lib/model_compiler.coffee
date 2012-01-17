caboose = require 'caboose'
Path = caboose.path
Compiler = caboose.Compiler
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
    @extends = matches[2]
    scope_var = "__scope_#{@name}__"
    @code = @code.replace(/class\W+([^\W]+)\W+extends\W+([^\W]*Model)/, "class @#{@name} extends #{@extends}")
    
    indent = /\n([ \t]+)/.exec(@code)
    indent = if indent? then indent[1] else '  '
    text = /([ \t]*)class\W+([^\W]+)\W+extends\W+([^\W]*Model)[^\n]*/.exec(@code)

    a = new RegExp("\n#{text[1]}[^ \t\n]").exec(@code.substr(text.index + text[0].length))
    if a?
      l = text.index + text[0].length + a.index
      @code = @code.substr(0, l) + "#{indent}#{scope_var} false\n" + @code.substr(l)

    text = text[0]
    @code = @code.replace(text, "#{text}\n#{indent}#{scope_var} true")
    
    @builder = new Builder(@name)
    
    @scope.Model = class __MODEL__
    @scope[scope_var] = (a) => @scope[scope_var] = a
    for k of @builder
      do (k) =>
        @scope[k] = (args...) =>
          throw new Error("#{k} is not defined") if @scope[scope_var] isnt true
          @builder[k](args...)
    
    while import_call = /import\W+('([^']+)'|"([^"]+)")/.exec(@code)
      import_object = global.registry.get import_call[2]
      import_object = import_object.class if import_object.type is 'controller'
      @scope[import_call[2]] = import_object
      @code = @code.replace import_call[0], ''

    # @apply_scope_plugins 'models'
    # @apply_precompile_plugins 'models'

  postcompile: ->
    methods = Object.keys(@scope[@name]::).filter (k) -> k isnt 'constructor'
    for method in methods
      @builder.instance method, @scope[@name]::[method]
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
