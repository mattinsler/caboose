bcrypt = require 'bcrypt'
rbytes = require 'rbytes'

module.exports = (objs) ->
  objs.Builder.plugins.authenticate_using = {
    pre_build: (username_field, password_field) ->
      @static 'encrypt_password', (value) ->
        salt = bcrypt.gen_salt_sync 10
        bcrypt.encrypt_sync value, salt
      
      @instance "change_#{password_field}", (value) ->
        @[password_field] = @_type.encrypt_password value
        
      @static 'authenticate', (username, password, callback) ->
        query = {}
        query[username_field] = username
        @where(query).first (err, user) =>
          return callback err unless user?

          bcrypt.compare password, user[password_field], (err, result) =>
            return callback err unless result

            if @_properties.authenticate_with_token? and not user[@_properties.authenticate_with_token[0]]?
              token_field = @_properties.authenticate_with_token[0]
              if not user[token_field]?
                update = {}
                user[token_field] = update[token_field] = module.exports.generate_token 32
                user.update {$set: update}

            callback null, user
  }
  objs.Builder.plugins.authenticate_with_token = {
    pre_build: (token_field) ->
      @static 'authenticate_token', (token, callback) ->
        query = {}
        query[token_field] = token
        @where(query).first callback
  }

module.exports.generate_token = (length) ->
  rbytes.randomBytes(length).toHex()
