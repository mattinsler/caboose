fs = require 'fs'
path = require 'path'

find_paths = (root) ->
  paths =
    app: path.join root, 'app'
    config: path.join root, 'config'
    plugins: path.join root, 'plugins'
    public: path.join root, 'public'
    test: path.join root, 'test'
    temp: path.join root, 'tmp'
  paths.controllers = path.join paths.app, 'controllers'
  paths.models = path.join paths.app, 'models'
  paths.helpers = path.join paths.app, 'helpers'
  paths.views = path.join paths.app, 'views'

  count = 0
  for f in ['controllers', 'models', 'helpers', 'views', 'config']
    ++count if path.existsSync paths[f]
  return paths if count > 2
  
  return null if root is '/'
  find_paths path.normalize("#{root}/../")

exports.get = (root) ->
  return exports.cached_paths if exports.cached_paths?
  exports.cached_paths = find_paths(root ? process.cwd())
  console.error 'Could not find a root for paths' if not exports.cached_paths?
  exports.cached_paths