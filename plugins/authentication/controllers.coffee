# unauthorized = (controller, realm) ->
#   controller._responder.res.writeHead 401, 'Content-Type': 'text/plain', 'WWW-Authenticate': "Basic realm=#{realm}"
#   controller._responder.res.end 'Authorization Required'
# 
# basic_auth_filter = (options) ->
#   realm = options.realm ? 'Realm'
#   (next) ->
#     return unauthorized this, realm unless @headers.authorization?
#     
#     matches = /^basic ([A-Za-z0-9=]+)$/i.exec @headers.authorization
#     return unauthorized this, realm unless matches?
#     
#     creds = new Buffer(matches[1], 'base64').toString('utf8').split ':'
#     return unauthorized this, realm unless creds.length is 2 and creds[0] is options.name and creds[1] is options.password
#     
#     next()
# 
# exports.compiler =
#   scope: {
#     http_basic_authenticate_with: (options) ->
#       throw new Error 'http_basic_authenticate_with requires name and password options' unless options?.name? and options?.password?
#       @filters.splice 0, 0, only: null, method: basic_auth_filter(options)
#   }