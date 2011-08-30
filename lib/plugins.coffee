fs = require 'fs'
path = require 'path'

get_with_base = (base, filename, moduleName) ->
  # console.log "Getting #{filename}.#{moduleName} plugins from #{base}"
  plugins = []
  if path.existsSync base
    for file in fs.readdirSync base
      try
        pluginModule = require path.join(base, file, filename)
        plugins.push pluginModule[moduleName] if pluginModule[moduleName]?
        # console.log "Installing plugin #{file}.#{filename}"
      catch e
        if !/^Cannot find module/.test e.message
          console.error e.stack
  plugins

exports.get = (filename, moduleName) ->
  plugins = get_with_base path.join(__dirname, '../plugins'), filename, moduleName
  plugins = plugins.concat(get_with_base Caboose.path.plugins, filename, moduleName)
  
  result = {}
  for plugin in plugins
    for k, v of plugin
      result[k] = [] unless result[k]?
      result[k].push v
  
  result