import 'Post'
import 'User'
import 'FormHelper'
import 'ApplicationController'

class PostsController extends ApplicationController
  helper FormHelper
  
  before_filter ((next) ->
    Post.where(_id: @params.id).first (err, post) =>
      return next(err) if err?
      return next(new Error("Could not find post with id #{@params.id}")) unless post?
      @post = post
      next()
  ), {only: ['show', 'edit', 'update', 'destroy']}
  
  before_filter ((next) ->
    return next() unless @params.users_id?
    User.where(_id: @params.users_id).first (err, user) =>
      return next(err) if err?
      return next(new Error("Could not find user with id #{@params.users_id}")) unless user?
      @user = user
      next()
  ), {only: ['index']}

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
