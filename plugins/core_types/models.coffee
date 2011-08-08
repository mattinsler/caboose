fs = require 'fs'
path = require 'path'

exports.compiler =
  precompile: ->
    base = path.join __dirname, 'types'
    for filename in fs.readdirSync base
      @scope[k] = v for k, v of require path.join base, filename