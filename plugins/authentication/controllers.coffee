unauthorized = ->
  @_responder.res.writeHead 401, 'Content-Type': 'text/plain', 'WWW-Authenticate': 'Basic realm=My Realm'
  @_responder.res.end 'Authorization Required'

exports.compiler =
  scope: {
    http_basic_authenticate_with: (options) ->
      throw new Error 'http_basic_authenticate_with requires name and password options' if not (options?.name? and options?.password?)
      
      @filters.splice 0, 0, only: null, method: (next) ->
        return unauthorized.call this unless @headers.authorization?
        
        matches = /^basic ([A-Za-z0-9=]+)$/i.exec @headers.authorization
        return unauthorized.call this unless matches?
        
        creds = new Buffer(matches[1], 'base64').toString('utf8').split ':'
        return unauthorized.call this unless creds.length is 2
      
        return unauthorized.call this unless creds[0] is options.name and creds[1] is options.password
        next()
  }