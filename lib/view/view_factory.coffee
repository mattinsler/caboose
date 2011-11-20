fs = require 'fs'
path = require 'path'

class View
  constructor: (@html) ->

class ViewFactory
  constructor: (htmlFilename) ->
    @html =
      filename: htmlFilename
      modified: new Date(0)
  create: ->
    stat = fs.statSync(@html.filename)
    if stat.mtime > @html.modified
      @html.template = fs.readFileSync(@html.filename, 'utf8')
      @html.modified = stat.mtime
    new View @html

    # fs.watchFile @paths.view, (curr, prev) =>
    #   if curr.mtime.getTime() isnt prev.mtime.getTime()
    #     fs.readFile @paths.view, 'utf8', (err, data) =>
    #       @viewTemplate = data if not err?
    #       console.log "#{@paths.view} reloaded!"
    
  @compile = (filename) ->
    return null if not path.existsSync filename
    new ViewFactory filename

module.exports = ViewFactory
