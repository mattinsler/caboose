fs = require 'fs'
PATH = require 'path'

module.exports = class Path
  constructor: (@path = process.cwd()) ->
    
  join: (subpaths...) ->
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
  readdir: (callback) ->
    fs.readdir @path, callback

  readdir_sync: ->
    fs.readdirSync @path

  read_file_sync: (encoding = null) ->
    fs.readFileSync @path, encoding

  write_file_sync: (data, encoding = null) ->
    fs.writeFileSync @path, data, encoding
