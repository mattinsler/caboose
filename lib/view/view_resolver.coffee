_ = require 'underscore'
Path = require '../path'

ViewResolver = {
  resolve_view: (root, view, format, is_partial) ->
    view = new Path(view)
    view = if view.is_absolute() then new Path(view.path.replace(/^\/+/, '')) else new Path(root).join(view.path)
    name = (if is_partial and view.filename[0] isnt '_' then '_' else '') + view.filename
    try
      files = (if view.is_absolute() then new Path(view.dirname) else Caboose.path.views.join(view.dirname)).readdir_sync()
      _(files).find((f) -> f.basename is "#{name}.#{format}") || _(files).find((f) -> f.basename is name)
    catch e

  resolve_layout: (controller, format) ->
    layouts_dir = Caboose.path.views.join('layouts')
    return @resolve_view(layouts_dir, controller, format) if typeof controller is 'string'

    c = Caboose.registry.get(controller._name)
    while c
      layout = @resolve_view(layouts_dir, c._short_name, format)
      return layout if layout?
      c = Caboose.registry.get(c._extends)
    null
}

module.exports = ViewResolver
