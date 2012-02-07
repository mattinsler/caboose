import 'Post'
import 'User'
import 'FormHelper'
import 'ApplicationController'

class PostsController extends ApplicationController
  helper FormHelper
  
  before_filter 'posts_filter', {only: ['show', 'edit', 'update', 'destroy']}
  before_filter 'users_filter', {only: ['index']}

  index: ->
    @count = Post.count()
    @posts = (if @user? then Post.where(user_id: @user._id) else Post).paginate(@query)
    @render()
  
  show: -> @render()
  
  new: ->
    @post = new Post()
    @render()
  
  create: ->
    @body.post.created_at = new Date()
    Post.save @body.post, (err, post) =>
      @redirect_to "/posts/#{post._id}"

  edit: -> @render()
  
  update: ->
    @body.post.updated_at = new Date()
    @post.update {$set: @body.post}, =>
      @redirect_to "/posts/#{@post._id}", {info: "Post #{@post._id} has been successfully updated!"}
  
  destroy: ->
    @post.remove =>
      @redirect_to '/posts', {info: "Post #{@post._id} has been deleted.  So Sad!"}
