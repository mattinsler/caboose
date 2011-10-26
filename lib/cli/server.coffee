_ = require 'underscore'

exports.description = 'Start app server'

load_models = (callback) ->
  for file in Caboose.path.models.readdir_sync()
    match = /^(.+)\.(js|coffee)$/.exec(file)
    Caboose.registry.get(match[1]) if match?
  callback()

log_memory = ->
  mem = process.memoryUsage()
  console.log "[CABOOSE] RSS=#{mem.rss} VSIZE=#{mem.vsize} HEAP_TOTAL=#{mem.heapTotal} HEAP_USED=#{mem.heapUsed}"
  setTimeout log_memory, 10000

exports.method = (args...) ->
  Caboose.app.initialize (app) ->
    load_models ->
      app.boot ->
        console.log "[CABOOSE] Listening on port #{app.address().port}"
        
        log_memory() if _(args).include('profile')
