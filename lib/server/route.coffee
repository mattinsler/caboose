_ = require 'underscore'

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

    ControllerType = Caboose.registry.get("#{@options.controller}_controller")
    return res.send(404) unless ControllerType?
    # return res.send(404) if controller_factory.responds_to? and req.params.format not in controller_factory.responds_to

    controller = new ControllerType(req, res, next)
    controller.execute @options.action

module.exports = Route
