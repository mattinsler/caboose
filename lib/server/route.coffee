path = require 'path'
Responder = require './responder'

class Route
  constructor: (spec, @controllerFactory, @viewFactory) ->
    @method = spec.method
    @action = spec.action
    @path = spec.path

  respond: (req, res, next) ->
    responder = new Responder @viewFactory, req, res, next
    controller = @controllerFactory.create responder
    controller.execute @action

  @create: (spec) ->
    viewFactory = app.registry.get "#{spec.controller}##{spec.action}_view"
    controllerFactory = app.registry.get "#{spec.controller}_controller"
    return null unless controllerFactory?
    new Route spec, controllerFactory, viewFactory

module.exports = Route