_ = require 'underscore'
Path = require './path'
logger = require './logger'

_npm_install = (package_obj, root, callback) ->
  callback = root if typeof root is 'function'
  root ||= Caboose.root
  root = new Path(root) unless root instanceof Path
  
  npm = require('npm')
  tmp_file = root.join(new Buffer(16).toString('hex') + '.tmp')
  stream = tmp_file.create_write_stream()
  logger.message "Trying to npm install #{package_obj}".green, 0
  npm.load {prefix: root.path, logfd: stream, outfd: stream, loglevel: 'silent'}, (err) ->
    return callback(err) if err?
    npm.commands.install [package_obj], (err, a, result, str) ->
      stream.destroy()
      tmp_file.unlink_sync()
      return callback(err) if err?
      logger.message "Successfully installed #{package_obj}!".green, 0
      callback()

util = module.exports =
  mkdir: (file_path, mode = 0o755) ->
    if file_path.exists_sync()
      logger.file_exists(file_path)
    else
      dirs = [file_path]
      dirs.push(file_path) until (file_path = file_path.join('..')).exists_sync()
      while (d = dirs.shift())
        logger.file_mkdir(d)
        d.mkdir_sync(mode)

  copy_dir: (from, to, options) ->
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
            if options?.replace?
              content = to_file.read_file_sync('utf8')
              for k, v of options.replace
                content = content.replace(new RegExp("%#{k}%", 'g'), v)
              to_file.write_file_sync(content, 'utf8')
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
    package_obj = util.read_package(root)
    alter_method(package_obj)
    util.write_package(package_obj, root)
  
  add_plugin_to_package: (plugin_name, version) ->
    util.add_dependency_to_package plugin_name, version
    util.alter_package (package_obj) ->
      package_obj['caboose-plugins'] = [] unless package_obj['caboose-plugins']?
      package_obj['caboose-plugins'].push(plugin_name) unless _(package_obj['caboose-plugins']).find((p) -> p is plugin_name)?
  
  remove_plugin_from_package: (plugin_name) ->
    util.remove_dependency_from_package plugin_name
    util.alter_package (package_obj) ->
      package_obj.dependencies = {} unless package_obj.dependencies?
      delete package_obj.dependencies[plugin_name]
      package_obj['caboose-plugins'] = [] unless package_obj['caboose-plugins']?
      package_obj['caboose-plugins'] = _(package_obj['caboose-plugins']).reject (p) -> p is plugin_name

  add_dependency_to_package: (plugin_name, version, root = Caboose.root) ->
    util.alter_package ((package_obj) ->
      package_obj.dependencies = {} unless package_obj.dependencies?
      package_obj.dependencies[plugin_name] = version
    ), root
  
  remove_dependency_from_package: (plugin_name) ->
    util.alter_package (package_obj) ->
      package_obj.dependencies = {} unless package_obj.dependencies?
      delete package_obj.dependencies[plugin_name]
  
  npm_install: (package_name, root, callback) ->
    callback = root if typeof root is 'function'
    root ||= Caboose.root
    root = new Path(root) unless root instanceof Path
    
    logger.title "Installing #{package_name}"
    done = (err) ->
      if err?
        logger.error "An error occured while running npm install #{package_name}"
        return callback and callback(err)
      util.add_dependency_to_package(package_name, util.read_package(root.join('node_modules', package_name)).version, root)
      logger.title "Installed #{package_name}"
      callback and callback(null, true)
    
    if root.join('node_modules', package_name).exists_sync()
      try
        require(package_name)
        return done()
      catch e
    
    logger.error "#{package_name} is not installed.  Installing with npm..."
    _npm_install(package_name, root, done)
