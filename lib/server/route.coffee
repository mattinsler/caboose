path = require 'path'
Responder = require './responder'

class Route
  constructor: (spec, @controllerFactory) ->
    @method = spec.method
    @action = spec.action
    @path = spec.path

  respond: (req, res, next) ->
    req.params.format ?= 'html'
    return res.send 404 if @controllerFactory.responds_to? and req.params.format not in @controllerFactory.responds_to
    
    responder = new Responder req, res, next
    controller = @controllerFactory.create responder
    controller.execute @action

  @create: (spec) ->
    controllerFactory = global.registry.get "#{spec.controller}_controller"
    return null unless controllerFactory?
    new Route spec, controllerFactory

module.exports = Route