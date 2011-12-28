require 'colors'

exports.description = 'Run plugin scripts'

bail = (plugin_name) ->
  console.log "Could not find a plugin named #{plugin_name}".red

exports.method = (plugin_name, command, args...) ->
  [plugin_name, command] = plugin_name.split(':') if !command? and /^[^:]+:[^:]+$/.test(plugin_name)
  
  try
    plugin = require(plugin_name)
    return bail(plugin_name) unless plugin?.cli?

    return console.log(Object.keys(plugin.cli).join('\n')) unless command?
    
    plugin.cli[command].method(args...)
  catch e
    bail(plugin_name)
