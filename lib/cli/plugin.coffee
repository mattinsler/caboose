require 'colors'

exports.description = 'Run plugin scripts'

help = (plugin_name, plugin) ->
  console.log '[CABOOSE] ' + "Commands available for #{plugin_name}".blue
  console.log()
  console.log '  ' + Object.keys(plugin.cli).join('  \n')
  console.log()

npm_install = (plugin_name, callback) ->
  npm = require('npm')
  npm.load {loglevel: 'silent'}, (err) ->
    return callback(err) if err?
    npm.commands.install [plugin_name], (err, a, result, str) ->
      return callback(err) if err?
      callback()

exports.method = (plugin_name, command, args...) ->
  return console.log('Must specify a plugin name'.red) unless plugin_name?
  
  [plugin_name, command] = plugin_name.split(':') if !command? and /^[^:]+:[^:]+$/.test(plugin_name)

  try
    plugin = require(plugin_name)
  catch e
    return console.log("Error while processing plugin #{plugin_name}".red) unless e.message is "Cannot find module '#{plugin_name}'"
    
    return console.log "Could not find a plugin named #{plugin_name}".red
    # return npm_install plugin_name, (err) ->
    #   return console.log(err.message) if err?
    #   exports.method(plugin_name, command, args...)
      
  return console.log("#{plugin_name} is not setup to be a caboose plugin".red) unless plugin?.cli?

  return help(plugin_name, plugin) unless command? and plugin.cli[command]?

  plugin.cli[command].method(args...)
