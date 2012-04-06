path = require 'path'

logger = module.exports =
  indent: '          '
  
  title: (message) -> console.log "[CABOOSE] #{message}"
  message: (message, indent_length = -1) ->
    ind = if indent_length < 0 then logger.indent else Array(indent_length).join(' ')
    return console.log ind + message.join("\n#{ind}") if Array.isArray(message)
    console.log "#{ind}#{message}"
  error: (message) ->
    console.log message.red
  file_exists: (file_path) ->
    console.log "#{logger.indent}exists  ".grey + file_path
  file_create: (file_path) ->
    console.log "#{logger.indent}create  ".green + file_path
  file_mkdir: (file_path) ->
    console.log "#{logger.indent}mkdir   ".blue + file_path
  file_alter: (file_path) ->
    console.log "#{logger.indent}alter   ".grey + file_path
  
  log: (message) ->
    [x, method, file, line, column] = /at ([^ ]+) [^(]*\(([^:]+):([^:]+):([^)]+)\)/.exec(new Error().stack.split('\n'))
    console.log "[#{method} (#{path.basename(file)}:#{line})] #{message}"
