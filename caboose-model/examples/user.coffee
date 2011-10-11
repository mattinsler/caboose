Model = require 'caboose-model'

User = Model.create('User')
            .store_in('user')
            .authenticate_using('email', 'password')
            .authenticate_with_token('auth_token')

User.static 'find_by_email', (email) ->
  @where {email: email}

User.instance 'full_name', ->
  "#{@first_name} #{@last_name}"

module.exports = User.build()
