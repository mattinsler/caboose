bcrypt = require 'bcrypt'
rbytes = require 'rbytes'

generate_token = (length) ->
  rbytes.randomBytes(length).toHex()

exports.compiler =
  scope: {
    password: (name, options) ->
      options ?= {}
      options.set = (value, field) ->
        salt = bcrypt.gen_salt_sync 10
        bcrypt.encrypt_sync value, salt

      @add_field 'string', name, options
      @_authentication ?= {}
      @_authentication.password = name
      
    auth_token: (name, options) ->
      @add_field 'string', name, options
      @_authentication ?= {}
      @_authentication.auth_token = name

    authenticate_by: (fields...) ->
      @_authentication ?= {}
      @_authentication.authenticate_by = fields
  }

  postcompile: ->
    return unless @_authentication?
    _authentication = @_authentication
    @add_static 'authenticate_with', (options, callback) ->
      # all of this can be used to double-check the field names and all that
      # also, the authenticated_by fields is to enable multiple fields to be used as the username
      #   for instance, if you wanted to look up by email and username, then it can be simplified
      #   for you by calling authenticate_with 'username', 'password' rather than what i have now
      
      # if using auth token field
      if _authentication.auth_token? and options[_authentication.auth_token]?
        query = {}
        query[_authentication.auth_token] = options[_authentication.auth_token]
        this.where(options).first callback

      # if has authenticate by and password fields and using password
      else if _authentication.authenticate_by? and _authentication.password? and options[_authentication.password]?
        password = options[_authentication.password]
        delete options[_authentication.password]
        this.where(options).first (err, user) =>
          return callback err unless user?

          bcrypt.compare password, user[_authentication.password], (err, result) =>
            return callback err if err?
            return callback() unless result

            if not user.auth_token?
              user.doc.auth_token = generate_token 32
              this.update {id: user.id}, {$set: {auth_token: user.auth_token}}
            
            callback null, user