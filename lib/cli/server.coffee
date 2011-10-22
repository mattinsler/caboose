exports.description = 'Start app server'

load_models = (callback) ->
  for file in Caboose.path.models.readdir_sync()
    match = /^(.+)\.(js|coffee)$/.exec(file)
    Caboose.registry.get(match[1]) if match?
  callback()

exports.method = ->
  Caboose.app.initialize (app) ->
    load_models ->
      app.boot ->
        console.log "Listening on port #{app.address().port}"
