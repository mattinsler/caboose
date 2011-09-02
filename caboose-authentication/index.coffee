bcrypt = require 'bcrypt'
rbytes = require 'rbytes'

module.exports = (objs) ->
  objs.Builder.plugins.authenticate_using = {
    pre_build: (username_field, password_field) ->
      @before_save (doc, next) ->
        return next() if not doc[password_field]?
        bcrypt.gen_salt 10, (err, salt) ->
          bcrypt.encrypt doc[password_field], salt, (err, hash) ->
            doc[password_field] = hash
            next()

      @static 'authenticate', (username, password, callback) ->
        query = {}
        query[username_field] = username
        @where(query).first (err, user) =>
          return callback err unless user?

          bcrypt.compare password, user[password_field], (err, result) =>
            return callback err unless result

            if @_properties.authenticate_with_token? and not user[@_properties.authenticate_with_token[0]]?
              token_field = @_properties.authenticate_with_token[0]
              user[token_field] = module.exports.generate_token 32
              query = {}
              query[username_field] = username
              update = {}
              update[token_field] = user[token_field]
              @update query, {$set: update}

            callback null, user
  }
  objs.Builder.plugins.authenticate_with_token = {
    pre_build: (token_field) ->
      @static 'authenticate_token', (token, callback) ->
        query = {}
        query[auth.token_field] = token
        @where(query).first callback
  }

module.exports.generate_token = (length) ->
  rbytes.randomBytes(length).toHex()