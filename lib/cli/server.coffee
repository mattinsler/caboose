_ = require 'underscore'

exports.description = 'Start app server'

load_models = (callback) ->
  if Caboose.path.models.exists_sync()
    for file in Caboose.path.models.readdir_sync()
      Caboose.registry.get(file.basename) if file.extension in ['js', 'coffee']
  callback()


log_memory = ->
  mem = process.memoryUsage()
  console.log "[CABOOSE] RSS=#{mem.rss} VSIZE=#{mem.vsize} HEAP_TOTAL=#{mem.heapTotal} HEAP_USED=#{mem.heapUsed}"
  setTimeout log_memory, 30000

exports.method = (args...) ->
  Caboose.app.initialize (app) ->
    load_models ->
      app.boot ->
        console.log "[CABOOSE] Listening on port #{app.address().port}"
        
        log_memory() if _(args).include('profile')
