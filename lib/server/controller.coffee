fs = require 'fs'
vm = require 'vm'
path = require 'path'
coffee = require 'coffee-script'

class Controller
  respond: (req, res, next) ->
    try
      console.log @paths.controller
      controller = new @controller.class()

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




class ControllerBuilder
  constructor: (@class, @filters) ->
  
  build: () ->
    new @class()
  
  @create: (name, filePath) ->
    return null if not path.existsSync("#{filePath}.coffee")

    key = (n.substring(0, 1).toUpperCase() + n.substring(1) for n in name.split '_').join ''

    code = fs.readFileSync "#{filePath}.coffee", 'utf8'
    code = code.replace new RegExp("class\\W+#{key}Controller", 'g'), "this.class = class #{key}Controller"

    compiled = coffee.compile code, filename: "#{filePath}.coffee"
    script = vm.createScript compiled, "#{filePath}.coffee"

    filters = []
    scope =
      Controller: Controller
      before_filter: (filter) ->
        filters.push filter

    script.runInNewContext scope

    new ControllerBuilder scope.class, filters
      
module.exports = ControllerBuilder