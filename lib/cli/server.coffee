exports.description = 'Start app server'

exports.method = ->
  Caboose.app.initialize (app) ->
    app.listen()
    console.log "Listening on port #{app.address().port}"