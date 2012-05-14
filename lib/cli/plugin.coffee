require 'colors'
util = Caboose.util
logger = Caboose.logger

exports.description = 'Run plugin scripts'

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

commands = {
  list: ->
    logger.title 'Installed Plugins'
    logger.message Caboose.app.plugins if Caboose.app.plugins?.length > 0

  install: (plugin_name) ->
    return logger.error('Must specify a plugin name') unless plugin_name?
    
    if Caboose.root.join('node_modules', plugin_name).exists_sync()
      try
        plugin = require(plugin_name)
        return logger.error("#{plugin_name} is not a caboose plugin") unless plugin['caboose-plugin']?
    
        logger.title "Installing #{plugin_name}..."
        plugin['caboose-plugin'].install(util, logger) if plugin['caboose-plugin'].install?
        util.add_plugin_to_package(plugin_name, util.read_package(Caboose.root.join('node_modules', plugin_name)).version)
        return logger.title "Installed #{plugin_name}..."
    
      catch e
        console.error e.stack
        return logger.error("Error while trying to install plugin #{plugin_name}: #{e.message}") unless e.message is "Cannot find module '#{plugin_name}'"
    
    logger.error "#{plugin_name} is not installed.  Installing with npm..."
    npm_install plugin_name, (err) ->
      if err?
        logger.error "An error occured while running npm install #{plugin_name}"
        return logger.error(err.stack)
      commands.install(plugin_name) # Try again
  
  uninstall: (plugin_name) ->
    util.remove_plugin_from_package plugin_name
    logger.title "Uninstalled #{plugin_name}..."
  
  create: (plugin_name) ->
    return logger.error('Must specify a plugin name') unless plugin_name?
    
    base = Caboose.root.join(plugin_name)
    return logger.error("Error: File or directory '#{plugin_name}' already exists") if base.exists_sync()
    
    template = new Caboose.exports.path(__dirname).join('..', '..', 'templates', 'plugin')
    logger.title "Creating a new Caboose plugin at #{base}"

    util.copy_dir template, base, {
      replace: {
        'PLUGIN-NAME': plugin_name
        YEAR: new Date().getFullYear()
        'USER-NAME': process.env.USER
        'USER-EMAIL': "#{process.env.USER}@gmail.com"
      }
    }
}

exports.method = (command, plugin_name, args...) ->
  return logger.error("Invalid command: #{command}") if command? and !commands[command]?
  commands[if command? then command else 'list'](plugin_name, args...)
