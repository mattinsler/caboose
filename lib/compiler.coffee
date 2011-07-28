fs = require 'fs'
vm = require 'vm'
path = require 'path'

module.exports = class Compiler
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