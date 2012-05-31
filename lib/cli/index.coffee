Path = require '../path'
switchback = require('switchback').program('caboose')

base = new Path(__dirname)
for file in base.readdir_sync()
  do (file) ->
    options = file.require()
    switchback.command(file.basename, options) if options.method

module.exports = switchback
