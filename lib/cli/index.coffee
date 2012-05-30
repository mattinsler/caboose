Path = require '../path'
switchback = require('switchback').program('caboose')

base = new Path(__dirname)
for file in base.readdir_sync()
  do (file) ->
    options = file.require()
  
    if options.method
      _method = options.method
      options.method = ->
        Caboose.app.command = file.basename
        Caboose.app.arguments = arguments
        _method(arguments...)
      switchback.command(file.basename, options)

module.exports = switchback
