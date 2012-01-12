# fs = require 'fs'
# vm = require 'vm'
# path = require 'path'
# coffee = require 'coffee-script'
# Controller = require './controller'
# 
# class ControllerFactory
#   constructor: (@name, @short_name, @extends, @class, filters, helpers) ->
#     @filters = if 'Controller' is @extends then filters else Caboose.registry.get(@extends).filters.concat filters
#     @helpers = if 'Controller' is @extends then helpers else Caboose.registry.get(@extends).helpers.concat helpers
#   
#   create: (responder) ->
#     controller = new @class()
#     controller._name = @name
#     controller._short_name = @short_name
#     controller._extends = @extends
#     controller._filters = @filters
#     controller._helpers = @helpers
#     controller._responder = responder
#     controller.request = responder.req
#     controller.response = responder.res
#     controller.cookies = responder.req.cookies
#     controller.session = responder.req.session
#     controller.body = responder.req.body
#     controller.params = responder.req.params
#     controller.query = responder.req.query
#     controller.headers = responder.req.headers
#     controller.init()
#     controller
# 
#   @compile = (filename) ->
#     return null if not path.existsSync filename
#     ControllerFactoryCompiler = require './controller_factory_compiler'
#     compiler = new ControllerFactoryCompiler()
#     # compiler.debug = true
#     try
#       compiler.compile_file filename
#     catch err
#       console.log "Error trying to compile ControllerFactory for #{filename}"
#       console.error err.stack
#       null
# 
# module.exports = ControllerFactory
