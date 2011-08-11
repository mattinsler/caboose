exports.compiler =
  precompile: ->
    while importCall = /import\W+('([^']+)'|"([^"]+)")/.exec @code
      importObject = global.registry.get importCall[2]
      importObject = importObject.class if importObject.type is 'controller'
      @scope[importCall[2]] = importObject
      @code = @code.replace importCall[0], ''