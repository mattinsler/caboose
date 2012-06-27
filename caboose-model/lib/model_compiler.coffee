caboose = Caboose.exports
Path = caboose.path
Compiler = caboose.Compiler
Builder = require './builder'

class ModelCompiler extends Compiler
  precompile: ->
    matches = /class\W+([^\W]+)(\W+extends\W+([^\W]+))?/.exec(@code)
    throw new Error 'Could not find a model defined' unless matches?

    @name = matches[1]
    @extends = matches[3]
    @code = @code.replace(/class\W+([^\W]+)(\W+extends\W+([^\W]+))?/, "class @#{@name}#{if @extends? then ' extends ' + @extends else ''}")
    
    if !@extends? or !/Model$/.test(matches[3])
      while import_call = /import\W+\(?\W*('([^']+)'|"([^"]+)")\W*\)?/.exec(@code)
        @code = @code.replace import_call[0], "#{import_call[2]} = Caboose.get('#{import_call[2]}')\n"
      return @not_model = true
    
    scope_var = "__scope_#{@name}__"
    
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
    
    while import_call = /^\W*import\W+('([^']+)'|"([^"]+)")/.exec(@code)
      import_object = Caboose.get import_call[2]
      import_object = import_object.class if import_object.type is 'controller'
      @scope[import_call[2]] = import_object
      @code = @code.replace import_call[0], ''
    
    while require_call = /^\W*require\W+('([^']+)'|"([^"]+)")/.exec(@code)
      @code = @code.replace require_call[0], "#{require_call[2]} = require '#{require_call[2]}'"

  postcompile: ->

  respond: ->
    return @scope[@name] if @not_model
    @builder.build(@scope[@name])

  @compile = (file) ->
    # Caboose.logger.log "compiling #{file}"
    file = new Path(file) unless Path.isPath(file)
    return null unless file.exists_sync()
    compiler = new ModelCompiler()
    try
      compiler.compile_file file.path
    catch err
      console.log "Error trying to compile Model for #{file.path}"
      console.error err.stack
      null
    
module.exports = ModelCompiler
