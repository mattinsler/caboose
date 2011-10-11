path = require 'path'
Responder = require './responder'
ControllerFactory = require '../controller/controller_factory'

class Route
  constructor: (@spec) ->
    @method = @spec.method
    @path = @spec.path
    @controller = @spec.controller
    @action = @spec.action

  respond: (req, res, next) ->
    unless req.params.format?
      if req.query.format?
        req.params.format = req.query.format
      else if req.headers.accept.indexOf('application/json') is 0
        req.params.format = 'json'
    req.params.format or= 'html'

    controller_factory = ControllerFactory.compile path.join(Caboose.path.controllers, "#{@controller}_controller.coffee")
    return res.send 404 if not controller_factory
    return res.send 404 if controller_factory.responds_to? and req.params.format not in controller_factory.responds_to
    
    responder = new Responder req, res, next
    controller = controller_factory.create responder
    controller.execute @action

module.exports = Route