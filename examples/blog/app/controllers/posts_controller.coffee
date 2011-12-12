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
    @render()
  
  new: ->
    @post = {}
    @render 'edit'
  
  create: ->
    Post.save @body.post, (err, post) =>
      @flash.info = "Successfully created post #{post.title}"
      @redirect_to "/posts/#{post._id}"
  
  edit: ->
    @render()
  
  update: ->
    @post.update {$set: @body.post}, (err) =>
      return @error(err) if err?
      @flash.info = 'Successfully updated post'
      @redirect_to 'back'
