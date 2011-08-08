fs = require 'fs'
vm = require 'vm'
path = require 'path'
Plugins = require './plugins'

module.exports = class Compiler
  get_plugins: (filename) ->
    @_plugins ?= {}
    @_plugins[filename] = Plugins.get filename, 'compiler' unless @_plugins[filename]
    @_plugins[filename]
  
  apply_scope_plugins: (filename) ->
    plugins = @get_plugins filename
    return unless plugins.scope?
    apply_plugin = (k, v) =>
      @scope[k] = => v.apply this, arguments
    for plugin in plugins.scope
      apply_plugin k, v for k, v of plugin

  apply_plugins: (filename, methodName) ->
    plugins = @get_plugins filename
    return unless plugins[methodName]?
    plugin.call this for plugin in plugins[methodName]

  apply_precompile_plugins: (filename) ->
    @apply_plugins filename, 'precompile'

  apply_postcompile_plugins: (filename) ->
    @apply_plugins filename, 'postcompile'

  apply_respond_plugins: (filename) ->
    @apply_plugins filename, 'respond'

  precompile: ->
    
  postcompile: ->
    
  respond: ->
    throw new Error 'You must define a respond method'
    
  compile_file: (fullPath) ->
    @fullPath = fullPath
    code = fs.readFileSync fullPath, 'utf8'
    @compile code
  
  compile: (code) ->
    @code = code
    @scope =
      global: global
      process: process
      console: console
    if @fullPath?
      @scope.require = (arg) =>
        if /^\.{0,2}\//.test arg
          require.call this, path.normalize(path.join path.dirname(@fullPath), arg)
        else
          require.call this, arg
    else
      @fullPath = 'tmp.coffee'
      @scope.require = require

    @precompile()
    
    if /\.coffee$/.test @fullPath
      coffee = require 'coffee-script'
      @code = coffee.compile @code, filename: @fullPath
    
    console.log @code if @debug
    vm.runInNewContext @code, @scope, @fullPath
    
    @postcompile()
    
    @respond()