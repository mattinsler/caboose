require('../lib/paths').get '/Users/mattinsler/node/analytics/app'

ControllerFactory = require '../lib/controller/controller_factory'
FooControllerFactory = ControllerFactory.compile '/Users/mattinsler/node/analytics/app/controllers/foo_controller.coffee'

console.log FooControllerFactory.class.prototype.index.toString()
controller = FooControllerFactory.create req: {params: null, query: null, headers: null}
console.log Object.getOwnPropertyNames(controller.__proto__)

# Model.connect 'mongodb://localhost/test', ->
#   Application.by_access_token('pgREtYTzw3v5kdnBVRlNb8nyCRSSWGm21PyYjzd0YLE0Njep2YLE3OWYfepCaRbg').first (err, app) ->
#     console.log app if not err?