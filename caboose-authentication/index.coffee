bcrypt = require 'bcrypt'
crypto = require 'crypto'
Model = require 'caboose-model'

generate_token = exports.generate_token = (length) ->
  crypto.randomBytes(Math.ceil(length / 2)).toString('hex').substr(0, length)

exports['caboose-plugin'] = {
  initialize: ->
    Model.Builder.add_plugin
      name: 'authenticate_using'
      execute: (username_field, password_field) ->
        @_authenticate_using = {username: username_field, password: password_field}
      build: (model) ->
        return unless @_authenticate_using?
        username_field = @_authenticate_using.username
        password_field = @_authenticate_using.password
    
        @static 'encrypt_password', (value) ->
          salt = bcrypt.gen_salt_sync 10
          bcrypt.encrypt_sync value, salt
    
        @instance "change_#{password_field}", (value) ->
          @[password_field] = @_type.encrypt_password value

    Model.Builder.add_plugin
      name: 'authenticate_with_token'
      execute: (token_field) -> @_authenticate_with_token = token_field
      build: (model) ->
        return unless @_authenticate_with_token?
        token_field = @_authenticate_with_token
    
        @static 'authenticate_token', (token, callback) ->
          query = {}
          query[token_field] = token
          @where(query).first callback

    Model.Builder.add_plugin
      build: (model) ->
        return unless @_authenticate_using?
    
        username_field = @_authenticate_using.username
        password_field = @_authenticate_using.password
        token_field = @_authenticate_with_token
    
        @static 'authenticate', (username, password, callback) ->
          query = {}
          query[username_field] = username
          @where(query).first (err, user) =>
            return callback err unless user?

            bcrypt.compare password, user[password_field], (err, result) =>
              return callback err unless result
          
              if token_field? and not user[token_field]?
                update = {}
                user[token_field] = update[token_field] = generate_token 32
                user.update {$set: update}

              callback null, user
}
