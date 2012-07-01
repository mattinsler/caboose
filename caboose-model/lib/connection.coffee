util = require 'util'
mongodb = require 'mongodb'
Model = require './model'
caboose_model = require '../index'

type_parse = (value) ->
  return parseInt(value) if parseInt(value).toString() is value
  return parseFloat(value) if parseFloat(value).toString() is value
  return true if value.toLowerCase() is 'true'
  return false if value.toLowerCase() is 'false'
  return null if value.toLowerCase() is 'null'
  return undefined if value.toLowerCase() is 'undefined'
  value

url_parse = (url) ->
  [_x, protocol, _x, auth, host, path, query] = /([^:]+):\/\/(([^:]+:[^@]+)@)?([^\/]+)(\/[^?]+)?(\?.+)?/.exec(url)
  if host.indexOf(',') >= 0
    hosts = host.split(',').map (h) ->
      [h, p] = h.split(':')
      p = parseInt(p) if p
      {host: h, port: p}
    host = null
  else
    [h, p] = host.split(':')
    p = parseInt(p) if p?
    host = h
    port = p
  
  if query?
    q = {}
    for kv in query.replace(/^\?/, '').split('&')
      [k, v] = kv.split('=')
      k = decodeURIComponent(k)
      v = type_parse(decodeURIComponent(v))
      
      q[k] = v
    query = q
  
  [user, password] = auth.split(':') if auth?
  
  {
    protocol: protocol
    host: host
    hosts: hosts
    path: path
    user: user
    password: password
    query: query
  }

module.exports = class Connection
  _parse_url: (conn_string) ->
    uri = url_parse(conn_string)
    uri.database = uri.path.replace(/\//g, '')
    uri

  open: (options, callback) ->
    return(callback null, @db) if @db?
    
    options = @_parse_url(options.url) if options.url?
    
    if options.host?
      server = new mongodb.Server(options.host, options.port ? 27017, auto_reconnect: true)
    else if options.hosts?
      server = new mongodb.ReplSetServers(options.hosts.map((h) ->
        new mongodb.Server(h.host, h.port ? 27017, auto_reconnect: true)
      ), options.query)
    
    unless @db?
      try
        @db = new mongodb.Db(options.database, server, native_parser: true)
      catch e
        @db = new mongodb.Db(options.database, server, override_used_flag: true)
      
    @db.open (err, db) =>
      # console.error(if err.stack? then err.stack else util.inspect(err, true, 5)) if err?
      return callback?(err) if err?
      # @registerModel m for m in @models if not err?
      if options.user? and options.password?
        @db.authenticate options.user, options.password, =>
          callback? err, @db
      else
        callback? err, @db
  close: ->
    if @db?
      @db.close()
      delete @db

  collection: (name, callback) ->
    @db.collection name, callback

  @create: (connection_name = 'default', callback) ->
    if typeof connection_name is 'function'
      callback = connection_name
      connection_name = 'default'
    
    done = ->
      if caboose_model.connections_pending[connection_name]?
        delete caboose_model.connections_pending[connection_name]
        caboose_model.emit('connected', connection_name, caboose_model.connections[connection_name])
      callback(null, caboose_model.connections[connection_name])
    
    # already have connection, so return it
    return done() if caboose_model.connections[connection_name]?
    
    return callback(new Error('No configuration found for caboose-model')) unless caboose_model.configs?
    return callback(new Error("No configuration found for #{connection_name} connection")) unless caboose_model.configs[connection_name]?
    
    # if connection is pending, listen for the connection and return it
    if caboose_model.connections_pending[connection_name]?
      listener = (name, conn) ->
        if name is connection_name
          caboose_model.removeListener('connected', listener)
          done()
      return caboose_model.on('connected', listener)
    
    caboose_model.connections_pending[connection_name] = true
    
    conn = new Connection()
    conn.open caboose_model.configs[connection_name], (err, c) ->
      if err?
        callback(err)
      else
        caboose_model.connections[connection_name] = c
        done()
