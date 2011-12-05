_ = require 'underscore'
Path = require '../path'
colors = require 'colors'

exports.description = 'Create a new Caboose project'

copy_dir = (from, to) ->
  for file in from.readdir_sync()
    if file.filename[0] isnt '.'
      to_file = to.join(file.filename)
      if file.is_directory_sync()
        console.log '[CABOOSE] create dir ' + to_file.toString().blue
        to_file.mkdir_sync(0755)
        copy_dir(file, to_file)
      else
        console.log '[CABOOSE] copy file  ' + to_file.toString().green
        file.copy_sync(to_file)

exports.method = (args...) ->
  template = new Path(__dirname).join('..', '..', 'templates', 'project')
  base = new Path()
  base.is_directory_empty (empty) ->
    return console.error('[CABOOSE] Error: Should not init in non-empty directory') unless empty
    copy_dir(template, base)
