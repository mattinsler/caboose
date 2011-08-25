Model = require('caboose').Model

module.exports = (config, next) ->
  config.http =
    enabled: true
    port: 3000

  config.base_url = 'http://localhost:3000'

  Model.connect 'mongodb://localhost/test', ->
    next()