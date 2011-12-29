_ = require 'underscore'
Path = require '../path'
require 'colors'

exports.description = 'Create a new Caboose project'

copy_dir = (from, to) ->
  for file in from.readdir_sync()
    if file.filename[0] isnt '.'
      to_file = to.join(file.filename)
      if file.is_directory_sync()
        console.log '          ' + 'mkdir'.blue + '  ' + to_file
        to_file.mkdir_sync(0755)
        copy_dir(file, to_file)
      else
        console.log '          ' + 'create'.green + ' ' + to_file
        file.copy_sync(to_file)

exports.method = (project_name) ->
  if project_name?
    base = new Path().join(project_name)
    return console.error("[CABOOSE] Error: File or directory '#{project_name}' already exists") if base.exists_sync()
    base.mkdir_sync(0755)
  else
    base = new Path()
    project_name = base.basename
  
  template = new Path(__dirname).join('..', '..', 'templates', 'project')
  base.is_directory_empty (empty) ->
    return console.error('[CABOOSE] Error: Should not init in non-empty directory') unless empty
    
    console.log '[CABOOSE] ' + 'create'.green + ' new app at ' + base
    copy_dir(template, base)
    package = JSON.parse(base.join('package.json').read_file_sync('utf8'))
    package.name = project_name
    base.join('package.json').write_file_sync(JSON.stringify(package, null, 2), 'utf8')
