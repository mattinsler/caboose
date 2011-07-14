Server = require './server'

exports.createServer = (routes) ->
  new Server routes