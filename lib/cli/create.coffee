Path = require '../path'
util = Caboose.util
logger = Caboose.logger

exports.description = 'Create a new Caboose project'

exports.method = (project_name) ->
  return logger.error('Must provide a project name') unless project_name?
  
  base = new Path().join(project_name)
  return logger.error("Error: File or directory '#{project_name}' already exists") if base.exists_sync()
  
  template = new Path(__dirname).join('..', '..', 'templates', 'project')
  logger.title "Creating a new Caboose project at #{base}"

  util.copy_dir template, base
  package = util.read_package base
  package.name = project_name
  util.write_package package, base
