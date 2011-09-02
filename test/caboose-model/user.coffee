Model = require('caboose-model')
          .add_plugin('caboose-authentication')
          .configure {
            host: 'localhost'
            port: 27017
            database: 'test'
          }

User = Model.create('User')
  .store_in('user')
  .authenticate_using('email', 'password')
  .authenticate_with_token('auth_token')
  .static('get_current', ->
    
  )
  .method('foobar', ->)
  .build()

# console.dir User

# User.save {
#   email: 'matt.insler@gmail.com'
#   password: 'password'
# }

User.authenticate 'matt.insler@gmail.com', 'password', (err, user) ->
  return console.error err.stack if err?
  console.dir user