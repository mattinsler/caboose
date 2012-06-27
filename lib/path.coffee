fs = require 'fs'
util = require 'util'
PATH = require 'path'

module.exports = class Path
  constructor: (path = process.cwd()) ->
    @path = PATH.normalize(path.toString())
    # [x, x, @basename, @extension] = /^(.*\/)?(?:$|(.+?)(?:(\.[^.]*$)|$))/.exec(@path)
    # @filename = (@basename or '') + (@extension or '')
    # @extension = @extension.slice(1) if @extension?
    
    @dirname = PATH.dirname(@path)
    @extension = PATH.extname(@path)
    @filename = PATH.basename(@path)
    @basename = PATH.basename(@path, @extension)
    @extension = @extension.replace(/^\.+/, '')
    
  @isPath: (candidate) ->
    candidate.path? and candidate.dirname? and candidate.filename? and candidate.basename?
    
  join: (subpaths...) ->
    subpaths = subpaths.map (p) -> if Path.isPath(p) then p.path else p
    new Path(PATH.join @path, subpaths...)
  
  toString: ->
    @path

  require: ->
    require @path

  # PATH METHODS
  exists: (callback) ->
    PATH.exists @path, callback

  exists_sync: ->
    PATH.existsSync @path

  # FS METHODS
  create_read_stream: ->
    fs.createReadStream @path
  
  create_write_stream: ->
    fs.createWriteStream @path
  
  mkdir: (mode = 0o777, callback) ->
    fs.mkdir @path, mode, callback
  
  mkdir_sync: (mode = 0o777) ->
    fs.mkdirSync @path, mode

  readdir: (callback) ->
    fs.readdir @path, (err, files) =>
      return callback(err) if err?
      callback(err, files.map (f) => @.join(f))

  readdir_sync: ->
    fs.readdirSync(@path).map (f) => @.join(f)
  
  readlink: (callback) ->
    fs.readlink @path, callback
  
  readlink_sync: ->
    fs.readlinkSync @path

  read_file_sync: (encoding = undefined) ->
    fs.readFileSync @path, encoding
  
  stat: (callback) ->
    fs.stat @path, callback
  
  stat_sync: ->
    fs.statSync @path

  write_file_sync: (data, encoding = undefined) ->
    fs.writeFileSync @path, data, encoding
  
  unlink: (callback) ->
    fs.unlink @path, callback
  
  unlink_sync: ->
    fs.unlinkSync @path

  # HELPER METHODS
  is_directory_empty: (callback) ->
    @readdir (err, files) ->
      return callback(err) if err? and 'ENOENT' isnt err.code
      callback(null, files.length is 0)
  
  is_directory_empty_sync: ->
    try
      return @readdir_sync().length is 0
    catch e
      throw e if e? and 'ENOENT' isnt e.code
    false
  
  copy: (to, callback) ->
    src = @
    src.exists (err, exists) ->
      return callback(err) if err?
      return callback(new Error("File #{src} does not exist.")) unless exists
    
      dest = if Path.isPath(to) then to else new Path(to)
      dest.exists (err, exists) ->
        return callback(err) if err?
        return callback(new Error("File #{to} already exists.")) if exists
        
        input = src.create_read_stream()
        output = dest.create_write_stream()
        util.pump(input, output, callback)
  
  copy_sync: (to) ->
    throw new Error("File #{@} does not exist.") unless @.exists_sync()
    dest = if Path.isPath(to) then to else new Path(to)
    throw new Error("File #{to} already exists.") if dest.exists_sync()

    dest.write_file_sync(@.read_file_sync())
  
  is_directory: (callback) ->
    @stat (err, stats) ->
      callback(err, if stats? then stats.isDirectory() else null)
  
  is_directory_sync: ->
    @stat_sync().isDirectory()
  
  is_absolute: ->
    @path[0] is '/'
