import 'Post'
import 'User'

class ApplicationController extends Controller
  posts_filter: (next) ->
    Post.where(_id: @params.id).first (err, post) =>
      return next(err) if err?
      return next(new Error("Could not find post with id #{@params.id}")) unless post?
      @post = post
      next()
  
  users_filter: (next) ->
    return next() unless @params.users_id?
    User.where(_id: @params.users_id).first (err, user) =>
      return next(err) if err?
      return next(new Error("Could not find user with id #{@params.users_id}")) unless user?
      @user = user
      next()
