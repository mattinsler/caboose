path = require 'path'
Responder = require './responder'

class Route
  constructor: (spec, @controllerFactory, @layoutFactory, @viewFactory) ->
    @method = spec.method
    @action = spec.action
    @path = spec.path

  respond: (req, res, next) ->
    format = req.params.format ? 'html'
    return res.send 404 if @controllerFactory.responds_to? and format not in @controllerFactory.responds_to
    
    responder = new Responder @layoutFactory, @viewFactory, req, res, next
    controller = @controllerFactory.create responder
    controller.execute @action

  @create: (spec) ->
    layoutFactory = global.registry.get "#layout_view"
    viewFactory = global.registry.get "#{spec.controller}##{spec.action}_view"
    controllerFactory = global.registry.get "#{spec.controller}_controller"
    return null unless controllerFactory?
    new Route spec, controllerFactory, layoutFactory, viewFactory

module.exports = Route