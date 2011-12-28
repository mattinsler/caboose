# Caboose-Model

  A [mongodb](http://mongodb.org/) model library for [caboose](http://www.caboosejs.com/)

## Installation

    npm install caboose-model

## Getting Started

First, add an initializer to your project (config/initializers/caboose-model.coffee):

    require 'caboose-model'

This will add model recognition to the Caboose import directive.

## Configuration

The above initializer will automatically connect to the database listed in the model configuration variable.  For instance, your config/development.coffee might look like this:

    module.exports = (config, next) ->
      config.model = {
        host: 'localhost'
        port: 27017
        database: 'caboose_model_dev'
      }
      next()

## Usage

Using models from a controller is dead simple.  Just import the model by name and make your calls.

    import 'Post'
    
    class PostsController extends Controller
      before_filter 'get_post', {only: ['show', 'edit', 'update']}
      
      get_post: (next) ->
        Post.where(_id: @params.id).first (err, post) =>
          return next(err) if err?
          return next(new Error("Failed to load post #{@params.id}")) unless post?
          @post = post
          next()
      
      show: -> @render()
      
      new: ->
        @post = new Post()
        @render 'edit'
  
      create: ->
        Post.save @body.post, (err, post) =>
          @redirect_to "/posts/#{post._id}", {info: "Successfully created post #{post.title}"}
      
      edit: -> @render()
      
      update: ->
        @post.update {$set: @body.post}, (err) =>
          return @error(err) if err?
          @redirect_to "/posts/#{@post._id}", {info: 'Successfully updated post'}


## API

## License

(The MIT License)

Copyright (c) 2011 Matt Insler &lt;matt.insler@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
