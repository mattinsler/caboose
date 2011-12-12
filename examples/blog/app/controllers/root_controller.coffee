import 'Post'
import 'ApplicationController'

class RootController extends ApplicationController
  index: ->
    # done = _.after 2, => @render()
    # Post.count().into(@, 'count').then(done)
    # Post.all().array().into(@, 'posts').then(done)
    
    Post.count (err, count) =>
      @count = count
      Post.all().array (err, posts) =>
        @posts = posts
        @render()
