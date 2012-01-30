_ = require 'underscore'
Path = require './path'
logger = Caboose.logger

_npm_install = (package, callback) ->
  npm = require('npm')
  tmp_file = Caboose.root.join(new Buffer(16).toString('hex') + '.tmp')
  stream = tmp_file.create_write_stream()
  logger.message "Trying to npm install #{package}".green, 0
  npm.load {prefix: Caboose.root.path, logfd: stream, outfd: stream, loglevel: 'silent'}, (err) ->
    return callback(err) if err?
    npm.commands.install [package], (err, a, result, str) ->
      stream.destroy()
      tmp_file.unlink_sync()
      return callback(err) if err?
      logger.message "Successfully installed #{package}!".green, 0
      callback()

util = module.exports =
  mkdir: (file_path, mode = 0755) ->
    if file_path.exists_sync()
      logger.file_exists(file_path)
    else
      dirs = [file_path]
      dirs.push(file_path) until (file_path = file_path.join('..')).exists_sync()
      while (d = dirs.shift())
        logger.file_mkdir(d)
        d.mkdir_sync(mode)

  copy_dir: (from, to) ->
    from = new Path(from) unless from instanceof Path
    to = new Path(to) unless to instanceof Path
    util.mkdir(to)
    
    _copy_dir = (from, to) ->
      for file in from.readdir_sync()
        if file.filename[0] isnt '.'
          to_file = to.join(file.filename)
          if file.is_directory_sync()
            util.mkdir to_file
            _copy_dir file, to_file
          else
            file.copy_sync to_file
            logger.file_create to_file
    _copy_dir from, to
    
  create_file: (file_path, content, encoding = 'utf8') ->
    file_path = new Path(file_path) unless file_path instanceof Path
    
    if file_path.exists_sync()
      logger.file_exists(file_path)
    else
      util.mkdir file_path.join('..')
      logger.file_create(file_path)
      file_path.write_file_sync content, encoding
  
  has_package: (root = Caboose.root) ->
    (if root instanceof Path then root else new Path(root)).join('package.json').exists_sync()
  
  read_package: (root = Caboose.root) ->
    root = new Path(root) unless root instanceof Path
    package_file = root.join('package.json')
    try
      JSON.parse(package_file.read_file_sync('utf8'))
    catch e
      throw new Error("Had trouble reading or parsing #{package_file}")
  
  write_package: (data, root = Caboose.root) ->
    root = new Path(root) unless root instanceof Path
    package_file = root.join('package.json')
    try
      logger.file_alter package_file
      package_file.write_file_sync(JSON.stringify(data, null, 2), 'utf8')
    catch e
      throw new Error("Had trouble writing #{package_file}")
  
  alter_package: (alter_method, root = Caboose.root) ->
    package = util.read_package(root)
    alter_method(package)
    util.write_package(package, root)
  
  add_plugin_to_package: (plugin_name, version) ->
    util.add_dependency_to_package plugin_name, version
    util.alter_package (package) ->
      package['caboose-plugins'] = [] unless package['caboose-plugins']?
      package['caboose-plugins'].push(plugin_name) unless _(package['caboose-plugins']).find((p) -> p is plugin_name)?
  
  remove_plugin_from_package: (plugin_name) ->
    util.remove_dependency_from_package plugin_name
    util.alter_package (package) ->
      package.dependencies = {} unless package.dependencies?
      delete package.dependencies[plugin_name]
      package['caboose-plugins'] = [] unless package['caboose-plugins']?
      package['caboose-plugins'] = _(package['caboose-plugins']).reject (p) -> p is plugin_name

  add_dependency_to_package: (plugin_name, version) ->
    util.alter_package (package) ->
      package.dependencies = {} unless package.dependencies?
      package.dependencies[plugin_name] = version
  
  remove_dependency_from_package: (plugin_name) ->
    util.alter_package (package) ->
      package.dependencies = {} unless package.dependencies?
      delete package.dependencies[plugin_name]
  
  npm_install: (package, callback) ->
    logger.title "Installing #{package}"
    done = (err) ->
      if err?
        logger.error "An error occured while running npm install #{package}"
        return callback and callback(err)
      util.add_dependency_to_package(package, util.read_package(Caboose.root.join('node_modules', package)).version)
      logger.title "Installed #{package}"
      callback and callback(null, true)
    
    if Caboose.root.join('node_modules', package).exists_sync()
      try
        require(package)
        return done()
      catch e
    
    logger.error "#{package} is not installed.  Installing with npm..."
    _npm_install package, done
