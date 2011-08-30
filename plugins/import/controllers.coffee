caboose = require 'caboose'

exports.compiler =
  precompile: ->
    while importCall = /import\W+('([^']+)'|"([^"]+)")/.exec @code
      importObject = caboose.registry.get importCall[2]
      importObject = importObject.class if importObject.class?
      @scope[importCall[2]] = importObject
      @code = @code.replace importCall[0], ''