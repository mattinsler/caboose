exports.compiler =
  scope: {
    responds_to: (formats...) ->
      @_responds_to = formats
  }
  
  respond: ->
    @response.responds_to = @_responds_to