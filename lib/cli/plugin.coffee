require 'colors'

exports.description = 'Run plugin scripts'

help = (plugin_name, plugin) ->
  console.log '[CABOOSE] ' + "Commands available for #{plugin_name}".blue
  console.log()
  console.log '  ' + Object.keys(plugin.cli).join('\n  ')
  console.log()

npm_install = (plugin_name, callback) ->
  npm = require('npm')
  tmp_file = Caboose.root.join(new Buffer(16).toString('hex') + '.tmp')
  stream = tmp_file.create_write_stream()
  console.log "Trying to npm install #{plugin_name}".green
  npm.load {prefix: Caboose.root.path, logfd: stream, outfd: stream, loglevel: 'silent'}, (err) ->
    return callback(err) if err?
    npm.commands.install [plugin_name], (err, a, result, str) ->
      stream.destroy()
      tmp_file.unlink_sync()
      return callback(err) if err?
      console.log "Successfully installed #{plugin_name}!".green
      callback()

exports.method = (plugin_name, command, args...) ->
  return console.log('Must specify a plugin name'.red) unless plugin_name?

  [plugin_name, command] = plugin_name.split(':') if !command? and /^[^:]+:[^:]+$/.test(plugin_name)

  original_paths = module.paths.slice()
  try
    module.paths = [Caboose.root.path]
    plugin = require(plugin_name)
    module.paths = original_paths
  catch e
    module.paths = original_paths
    return console.log("Error while processing plugin #{plugin_name}".red) unless e.message is "Cannot find module '#{plugin_name}'"
    
    console.log "Could not find a plugin named #{plugin_name}".red
    return npm_install plugin_name, (err) ->
      return console.log(err.message) if err?
      exports.method(plugin_name, command, args...)
      
  return console.log("#{plugin_name} is not setup to be a caboose plugin".red) unless plugin?.cli?

  return help(plugin_name, plugin) unless command? and plugin.cli[command]?

  plugin.cli[command].method(args...)
