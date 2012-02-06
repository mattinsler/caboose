module.exports = ->
  @route '/', 'posts#index'
  @resources 'posts'
  @resources 'users', ->
    @resources 'posts'
