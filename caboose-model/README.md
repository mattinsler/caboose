# Caboose-Model

  A [mongodb](http://mongodb.org/) model library for [caboose](http://www.caboosejs.com/)

## Installation

    npm install caboose-model

## Getting Started

### Using `caboose plugin`

    $ caboose plugin caboose-model install

### Manually

First install caboose-model using npm as above.  Make sure to add caboose-model to your package.json file as well.

Then add an initializer to your project (config/initializers/caboose-model.coffee):

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

### Create a model

Create a User model with `caboose plugin`

    $ caboose plugin caboose-model new User

This will create a new file at app/models/user.coffee that looks like this:

    class User extends Model
      store_in 'user'

You can also create a model in javascript if you'd like.  For the equivalent User model, simply create a file at app/models/user.js that looks like this:

    var Model = require('caboose-model');

    var User = Model.create('User')
                    .store_in('user');

    module.exports = User.build();

### Use model from a Controller

Using models from a controller is dead simple.  Just import the model by name and make your calls.

    import 'User'
    
    class UsersController extends Controller
      before_action 'get_user', {only: ['show', 'edit', 'update']}
      
      get_user: (next) ->
        User.where(_id: @params.id).first (err, user) =>
          return next(err) if err?
          return next(new Error("Failed to load user #{@params.id}")) unless post?
          @user = user
          next()
      
      show: -> @render()
      
      new: ->
        @user = new User()
        @render 'edit'
  
      create: ->
        User.save @body.user, (err, user) =>
          @redirect_to "/users/#{user._id}", {info: "Successfully created user #{user.name}"}
      
      edit: -> @render()
      
      update: ->
        @user.update {$set: @body.user}, (err) =>
          return @error(err) if err?
          @redirect_to "/users/#{@user._id}", {info: 'Successfully updated user'}

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
