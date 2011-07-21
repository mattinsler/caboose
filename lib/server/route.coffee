class Route
  constructor: (@server, @route) ->
    
    
    
  @addToRouter: (router, routeSpec) ->
    console.log "#{route.method} #{route.path}"
    builder = Controller.create
    router.route method: routeSpec.method, path: routeSpec.path, to: builder
    @server[route.method] route.path, (req, res, next) -> responder.respond req, res, next
    
    
    @paths = 
      view: path.join @app.paths.views, @route.controller, @route.action + '.html.ejs'
      controller: path.join @app.paths.controllers, @route.controller + '_controller'
      helper: path.join @app.paths.helpers, @route.controller + '_helper'
    
    @controller = Controller.create @route.controller, @paths.controller