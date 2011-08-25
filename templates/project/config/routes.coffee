module.exports = (done) ->
  @match '/', controller: 'home'
  # @match '/signup', 'root#signup'
  # @match '/signup', method: 'post', controller: 'authentication', action: 'signup'
  # @match '/login', method: 'post', controller: 'authentication', action: 'login'
  # @match '/logout', 'authentication#logout'
  
  # @resources 'user'
      
  done and done()