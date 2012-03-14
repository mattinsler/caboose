_ = require 'underscore'
Path = require '../path'
mime = require 'mime'

View = {
  _renderers: {}
  register_renderer: (type, handler) ->
    type = mime.lookup(type)
    throw new Error("A renderer for #{type} is already registered") if @_renderers[type]?
    @_renderers[type] = handler

  render: (content_type, opts, callback) ->
    # {
    #   code: 
    #   content: (Error | 'html' | string)
    #   controller:
    #   view:
    #   options:
    # }
    renderer = @_renderers[content_type]
    return @next(new Error("There is no renderer registered for #{content_type}")) unless renderer?
    renderer opts, callback
}

View.register_renderer 'html', require './renderers/consolidate_renderer'
View.register_renderer 'txt', require './renderers/consolidate_renderer'
View.register_renderer 'json', require './renderers/json_renderer'

module.exports = View
