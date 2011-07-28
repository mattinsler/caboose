fs = require 'fs'
vm = require 'vm'
path = require 'path'
coffee = require 'coffee-script'
Controller = require './controller'

class ControllerFactory
  constructor: (@class, @filters) ->
  
  create: (responder) ->
    controller = new @class()
    controller.filters = @filters
    controller.responder = responder
    controller.params = responder.req.cookies
    controller.params = responder.req.session
    controller.body = responder.req.body
    controller.params = responder.req.params
    controller.query = responder.req.query
    controller.headers = responder.req.headers
    controller

  @compile = (filename) ->
    return null if not path.existsSync filename
    ControllerFactoryCompiler = require './controller_factory_compiler'
    registry = global.registry ? new (require '../registry')()
    compiler = new ControllerFactoryCompiler(registry)
    # compiler.debug = true
    try
      compiler.compile_file filename
    catch err
      console.log "Error trying to compile ControllerFactory for #{filename}"
      console.error err.stack
      null

module.exports = ControllerFactory