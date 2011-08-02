fs = require 'fs'
path = require 'path'
paths = require('./paths').get()

get_with_base = (base, filename, moduleName) ->
  plugins = []
  if path.existsSync base
    for file in fs.readdirSync base
      try
        pluginModule = require path.join(base, file, filename)
        plugins.push pluginModule[moduleName] if pluginModule[moduleName]?
      catch e
        # console.error e.stack
  plugins

exports.get = (filename, moduleName) ->
  plugins = get_with_base path.join(__dirname, '../plugins'), filename, moduleName
  plugins = plugins.concat(get_with_base paths.plugins, filename, moduleName) if paths?.plugins?
  
  result = {}
  for plugin in plugins
    for k, v of plugin
      result[k] = [] unless result[k]?
      result[k].push v
  
  result