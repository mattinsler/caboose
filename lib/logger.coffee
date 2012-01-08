logger = module.exports =
  indent: '          '
  
  title: (message) -> console.log "[CABOOSE] #{message}"
  message: (message) ->
    return console.log logger.indent + message.join("\n#{logger.indent}") if Array.isArray(message)
    console.log "#{logger.indent}#{message}"
  error: (message) ->
    console.log message.red
  file_exists: (file_path) ->
    console.log "#{logger.indent}exists ".grey + file_path
  file_create: (file_path) ->
    console.log "#{logger.indent}create ".green + file_path
  file_mkdir: (file_path) ->
    console.log "#{logger.indent}mkdir ".blue + file_path
  file_alter: (file_path) ->
    console.log "#{logger.indent}alter ".grey + file_path
