bcrypt = require 'bcrypt'
rbytes = require 'rbytes'

generate_token = (length) ->
  rbytes.randomBytes(length).toHex()

exports.compiler =
  precompile: ->
    @scope.authenticate_using = (username_field, password_field) =>
      @_authentication ?= {}
      @_authentication.username_field = username_field
      @_authentication.password_field = password_field
    
    @scope.authenticate_with_token = (token_field) =>
      @_authentication ?= {}
      @_authentication.token_field = token_field

  postcompile: ->
    auth = @_authentication
    return unless auth?

    if auth.token_field?
      @add_static 'authenticate_token', (token, callback) ->
        query = {}
        query[auth.token_field] = token
        @where(query).first callback

    if auth.username_field? and auth.password_field?
      password_field = @find_field_by_name auth.password_field
      password_field.set = (value, field) ->
        salt = bcrypt.gen_salt_sync 10
        bcrypt.encrypt_sync value, salt
      
      @add_static 'authenticate', (username, password, callback) ->
        query = {}
        query[auth.username_field] = username
        @where(query).first (err, user) =>
          return callback err unless user?
          
          bcrypt.compare password, user[auth.password_field], (err, result) =>
            return callback err unless result
            
            if auth.token_field? and not user[auth.token_field]?
              user[auth.token_field] = generate_token 32
              query = {}
              query[auth.username_field] = username
              update = {}
              update[auth.token_field] = user[auth.token_field]
              @update query, {$set: update}
              
            callback null, user