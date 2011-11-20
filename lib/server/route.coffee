_ = require 'underscore'
Responder = require './responder'
ControllerFactory = require '../controller/controller_factory'

class Route
  @lookup_type: (type_string) ->
    return 'json' if type_string.indexOf('application/json') is 0
    null

  constructor: (@options) ->
    throw new Error('Route options must have method') unless @options.method
    throw new Error('Route options must have controller') unless @options.controller
    throw new Error('Route options must have action') unless @options.action
  
  respond: (req, res, next) ->
    _.extend(req.params, @options)
    req.params.format = req.query.format || Route.lookup_type(req.headers.accept) || 'html' unless req.params.format?

    controller_factory = ControllerFactory.compile Caboose.path.controllers.join("#{@options.controller}_controller.coffee").toString()
    return res.send 404 if not controller_factory
    return res.send 404 if controller_factory.responds_to? and req.params.format not in controller_factory.responds_to
    
    responder = new Responder(req, res, next)
    controller = controller_factory.create responder
    controller.execute @options.action

module.exports = Route
