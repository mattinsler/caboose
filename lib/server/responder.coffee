fs = require 'fs'
ejs = require 'ejs'
path = require 'path'
Controller = require './controller'

module.exports = class Responder
  constructor: (@app, @route) ->
    @paths = 
      view: path.join @app.paths.views, @route.controller, @route.action + '.html.ejs'
      controller: path.join @app.paths.controllers, @route.controller + '_controller'
      helper: path.join @app.paths.helpers, @route.controller + '_helper'
    
    @controller = Controller.create @route.controller, @paths.controller
      
    if path.existsSync @paths.view
      @viewTemplate = fs.readFileSync @paths.view, 'utf8'
      fs.watchFile @paths.view, (curr, prev) =>
        if curr.mtime.getTime() isnt prev.mtime.getTime()
          fs.readFile @paths.view, 'utf8', (err, data) =>
            @viewTemplate = data if not err?
            console.log "#{@paths.view} reloaded!"
  
  respond: (req, res, next) ->
    try
      controller = @controller.build()
      # console.log @paths.controller
      # controller = new @controller.class()

      controller.render = () =>
        return res.send 404 if err? if not @viewTemplate?
        try
          html = ejs.render @viewTemplate, {
            locals: controller
            filename: @paths.view
          }
          res.send html, 200
        catch e
          next e

      controller[@route.action]()
    catch e
      next e