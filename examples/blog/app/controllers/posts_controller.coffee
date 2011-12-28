import 'Post'
import 'ApplicationController'

class PostsController extends ApplicationController
  before_filter 'get_post', {only: ['show', 'edit', 'update']}
  
  get_post: (next) ->
    Post.where({_id: @params.id}).first (err, post) =>
      return next(err) if err?
      return next(new Error("Failed to load post #{@params.id}")) unless post?
      @post = post
      next()
  
  show: ->
    @render '_post'
  
  new: ->
    @post = {}
    @render 'edit'
  
  create: ->
    @body.post.created_at = new Date()
    Post.save @body.post, (err, post) =>
      @redirect_to "/posts/#{post._id}", {info: "Successfully created post #{post.title}"}
  
  edit: ->
    @render()
  
  update: ->
    @post.update {$set: @body.post}, (err) =>
      return @error(err) if err?
      @redirect_to "/posts/#{@post._id}", {info: 'Successfully updated post'}
