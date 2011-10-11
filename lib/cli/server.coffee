exports.description = 'Start app server'

exports.method = ->
  Caboose.app.initialize (app) ->
    app.boot ->
      console.log "Listening on port #{app.address().port}"
