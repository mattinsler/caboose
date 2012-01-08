_ = require 'underscore'

exports.description = 'Start app server'

log_memory = ->
  mem = process.memoryUsage()
  console.log "[CABOOSE] RSS=#{mem.rss} VSIZE=#{mem.vsize} HEAP_TOTAL=#{mem.heapTotal} HEAP_USED=#{mem.heapUsed}"
  setTimeout log_memory, 30000

exports.method = (args...) ->
  Caboose.app.load_models()
  Caboose.app.boot ->
    console.log "[CABOOSE] Listening on port #{Caboose.app.address().port}"
    
    log_memory() if _(args).include('profile')
