Model = require '../lib/model/model'
Application = Model.compile '/Users/mattinsler/node/analytics/app/models/application.coffee'

Model.connect 'mongodb://localhost/test', ->
  Application.by_access_token('pgREtYTzw3v5kdnBVRlNb8nyCRSSWGm21PyYjzd0YLE0Njep2YLE3OWYfepCaRbg').first (err, app) ->
    console.log app if not err?