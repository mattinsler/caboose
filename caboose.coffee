path = require 'path'
Application = require './lib/application'

exports.start = (options) ->
  app = new Application()
  
  paths = {}
  if typeof options is 'string'
    paths.app = path.join options, 'app'
    paths.controllers = path.join paths.app, 'controllers'
    paths.models = path.join paths.app, 'models'
    paths.helpers = path.join paths.app, 'helpers'
    paths.views = path.join paths.app, 'views'
    paths.config = path.join options, 'config'
  app.paths = paths

  # read config
  config =
    http:
      enabled: true
      port: 3000

  app.initialize config
  app.listen()