fs = require 'fs'
path = require 'path'

base = path.join __dirname, 'types'

scope = {}
for filename in fs.readdirSync base
  scope[k] = v for k, v of require path.join base, filename

exports.compiler =
  scope: scope