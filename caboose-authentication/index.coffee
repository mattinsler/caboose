bcrypt = require 'bcrypt'
crypto = require 'crypto'
caboose = require 'caboose'

generate_token = exports.generate_token = (length) ->
  crypto.randomBytes(Math.ceil(length / 2)).toString('hex').substr(0, length)

initialize_model = (Model) ->
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

unauthorized = (controller, realm) ->
  controller._responder.res.writeHead 401, 'Content-Type': 'text/plain', 'WWW-Authenticate': "Basic realm=#{realm}"
  controller._responder.res.end 'Authorization Required'

basic_auth_filter = (options) ->
  realm = options.realm ? 'Basic'
  (next) ->
    return unauthorized(this, realm) unless @headers.authorization?
    
    matches = /^basic ([A-Za-z0-9=]+)$/i.exec @headers.authorization
    return unauthorized(this, realm) unless matches?
    
    creds = new Buffer(matches[1], 'base64').toString('utf8').split ':'
    return unauthorized(this, realm) unless creds.length is 2 and creds[0] is options.name and creds[1] is options.password
    
    next()

initialize_controller = ->
  caboose.controller.Builder.add_plugin
    name: 'http_basic_authenticate_with'
    execute: (options) ->
      throw new Error('http_basic_authenticate_with requires name and password options') unless options?.name? and options?.password?
      @_http_basic_authenticate_with = options
    build: (controller) ->
      @before_action basic_auth_filter(@_http_basic_authenticate_with) if @_http_basic_authenticate_with?

exports['caboose-plugin'] = {
  install: (util, logger) ->
  
  initialize: ->
    initialize_controller()
    try
      initialize_model require('caboose-model')
    catch e
}
