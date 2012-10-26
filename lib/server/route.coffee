_ = require 'underscore'
mime = require 'mime'

class Route
  @lookup_type: (type_string) ->
    return null unless type_string?
    return mime.extension(type_string)
    null

  constructor: (@options) ->
    throw new Error('Route options must have method') unless @options.method
    throw new Error('Route options must have controller') unless @options.controller
    throw new Error('Route options must have action') unless @options.action

  respond: (req, res, next) ->
    _.extend(req.params, @options)
    req.params.format = req.query.format || Route.lookup_type(req.headers.accept) || 'html' unless req.params.format?

    ControllerType = Caboose.registry.get("#{@options.controller}_controller")
    return next(new Error("Could not find #{@options.controller}_controller")) unless ControllerType?

    controller = new ControllerType(req, res, next)
    controller._execute(@options.action)

module.exports = Route
