# THIS DOCUMENT IS A WORK IN PROGRESS.

Please send me a message with anything that is not clear enough.

# Caboose

A [coffeescript](http://coffeescript.org)-happy [express](http://expressjs.com/)-based server-side MVC framework based on [Rails](http://rubyonrails.org/)
  
### Useful Plugins
  
[caboose-model](https://github.com/mattinsler/caboose/tree/master/caboose-model) - A mongodb model library for caboose

## Installation

```bash
npm install caboose
```

## Getting Started

```bash
$ caboose new app_name
$ cd app_name
$ npm install
$ caboose server
```

## Project Directory Structure

    + root
      + app
        + controllers
          | application_controller.coffee
        + helpers
          | application_helper.coffee
        + views
          + application
            | index.html.ejs
          + layouts
            | application.html.ejs
      + config
        | application.coffee
        + environments
          | development.coffee
          | production.coffee
        + initializers
        | middleware.coffee
        | routes.coffee
      + lib
      | package.json
      + public
      | README.md

## Naming Conventions Matter

Throughout caboose, file and class naming is very important.  These conventions allow for flexibility and ease of use.

In some cases, files with js and coffee extensions are used completely differently.  These cases will be identified in the documentation.
In all other cases all code can be written in javascript rather than coffeescript.  Just change the file extension to js and go to town.

## Boot Process

- Parse routes from config/routes.coffee
- Execute configuration files
  - Execute config/application.coffee
  - Execute config/environments/[current environment].coffee (if it exists)
- Execute all initializers in config/initializers in alphanumeric order
- Create http server using [express](http://expressjs.com/)
- Execute config/middleware.coffee
- Tell the http server to start listening on the configured port
- Execute all post_boot hooks configured during initialization

## Configuration

### The current environment

The environment is set through the CABOOSE_ENV environment variable.  If CABOOSE_ENV is not set, it will default to `development`.

### Config Files

Config files are executed during the boot process and are asynchronous.  You can change the config object passed in and when you're done, just call next().  The default application config file looks like this:

```coffeescript
module.exports = (config, next) ->
  config.http =
    enabled: true
    port: process.env.PORT || 3000

  next()
```

#### config/application.coffee

The global configuration file.  This will always be executed first.

#### config/environments

All environment-specific configuration files will be located here.  Environment-specific config files will be executed after the global
config file and operate the same way.  Edit the config object passed in and call next().

To create a config file for a specific environment, just create a module with the same name as the environment.  So for the development
environment, config/environments/development.coffee would run.

NOTE: Like most of Caboose, if you'd like to write your config files in javascript, just rename [environment].coffee to [environment].js.

### config/middleware.coffee

This file allows you to customize your entire middleware stack.  You are passed the http object and can configure any middleware you'd like.
Please note that the Caboose router is used by default and is configured by the routing DSL specified in the config/routes.coffee file.

The default middleware file looks like this:

```coffeescript
express = require 'express'

module.exports = (http) ->
  http.use express.bodyParser()
  http.use express.methodOverride()
  http.use express.cookieParser()
  http.use express.session(secret: 'some kind of random string')
  http.use -> Caboose.app.router.route.apply(Caboose.app.router, arguments)
  http.use express.static Caboose.root.join('public').path
```

### config/routes.coffee

This file contains the routing setup for your application.  It configures the Caboose router.

## Routing

Although Caboose sits on top of `express`, Caboose has it's own router.

The Caboose routing DSL seeks to be flexible and simple.  The routes file is loaded as a module and should export a single function.
This function have access to the routing DSL methods.

Here's a very simple routes.coffee file to demonstrate the structure:

```coffeescript
module.exports = ->
  @route '/', 'application'             # Route requests for GET / to the ApplicationController's index action

  @route '/posts', 'posts'              # Route requests for GET /posts to the PostsController's index action
  @route 'post /posts', 'posts#create'  # Route requests for POST /posts to the PostsController's create action
```

Each route has 4 properties; The method, path, controller and action.

The path must be specified in the first arguments to @route and can optionally include the method.
If no method is included it is defaulted to GET.  All properties except for the path can also be specified in the second argument.

For instance, the following lines are all equivalent.

```coffeescript
@route '/path', 'controller'
@route 'get /path', 'controller'
@route '/path', 'controller', {method: 'get', action: 'index'}
@route 'get /path', 'controller', {action: 'index'}
@route '/path', {controller: 'controller'}
@route '/path', {method: 'get', controller: 'controller'}
@route '/path', {controller: 'controller', action: 'index'}
@route '/path', {method: 'get', controller: 'controller', action: 'index'}
@route 'get /path', {controller: 'controller', action: 'index'}
```

### Parameters

Parameters can be specified on routes in the same way as frameworks like `express` or `rails` by putting a colon before the route segment.
These parameters will then be available from the `@params` object with a controller action.

So for a route like

```coffeescript
@route '/users/:id', 'users#show'
```

You can then access the user's id like this:

```coffeescript
class UsersController extends Controller
  show: ->
    console.log "The user's id is #{@params.id}"
    @render()
```

You can also add parameters to any route, by setting them on the options object, like this:

```coffeescript
@route '/superheroes/green-lantern', 'superheroes', {codename: 'green lantern'}
```

Any parameters that you set on a route will be available in the @params object from within controller action.
So in this case, you could access the codename of the /superheroes/green-lantern from the index action on the SuperheroesController at `@params.codename`.

### Parameter Conditions

Conditions can be set on any parameters in a route.  Just pass a conditions object to the route:

```coffeescript
# Restrict id to the string 'green-lantern'
@route '/superheroes/:id', 'superheroes', {conditions: {id: 'green-lantern'}}

# Restrict id to any of the strings 'green-lantern', 'alan-scott' or 'hal-jordan'
@route '/superheroes/:id', 'superheroes', {conditions: {id: ['green-lantern', 'alan-scott', 'hal-jordan']}}

# Restrict the id to any string matching the regular expression /green/i
@route '/superheroes/:id', 'superheroes', {conditions: {id: /green/i}}

# Restrict the id to an integer
@route '/superheroes/:id', 'superheroes', {conditions: {id: (id, request) -> parseInt(id) is id}}
```

### Resources Routing

Resourceful routing is available with the resources method:

```coffeescript
@resources 'superheroes'
```

This will create all resourceful routes for the SuperheroesController.  This is the equivalent of:

```coffeescript
@route '/superheroes', 'superheroes#index'
@route '/superheroes/new', 'superheroes#new'
@route 'post /superheroes', 'superheroes#create'
@route '/superheroes/:id', 'superheroes#show'
@route '/superheroes/:id/edit', 'superheroes#edit'
@route 'put /superheroes/:id', 'superheroes#update'
@route 'delete /superheroes/:id', 'superheroes#destroy'
```

### Domain Routing

```coffeescript
@domain 'caboosejs.com', ->
  @route '/', 'caboosejs_com'

@domain 'caboosejs.org' ->
  @route '/', 'caboosejs_org'

@route '/foo', 'foo', {conditions: {domain: 'caboosejs.com'}}
```

### Subdomain Routing

```coffeescript
@subdomain 'www', ->
  @route '/', 'caboosejs_com'

@subdomain ((subdomain, request) ->
    # put the subdomain into the params object
    request.params.codename = subdomain
    true
  ), ->
  @route '/', 'caboosejs_org'

@route '/foo', 'foo', {conditions: {subdomain: 'foo'}}
```

## Controllers

Controllers are located in the app/controllers directory.

## Views

Controllers are located in the app/views directory.

### Rendering Engines

View rendering is done through the [consolidate](https://github.com/visionmedia/consolidate.js) project and supported rendering engines can be found on consolidate's github page.
Views can be written using any of the rendering engines supported by consolidate.  Just npm install the rendering engine or add it to your package.json and go!
You can even mix and match engines for each view.

### Naming

#### File

[action].[format].[engine]

For instance, index.html.ejs would be the index action, where the client requests an html document, and using the ejs rendering engine.

#### Directory

Views for a controller are located within a directory with the same name as the controller.  For instance, if you 
have a controller named UsersController which would be in the file app/controllers/users_controller.coffee, then the
views would be in the app/views/users directory.

### Layouts

Layouts are located within the app/views/layouts directory.  The default layout is always application.html.[engine].
If you would like to override the layout for a specific controller, just create a layout named [controller].html.[engine]
in the layouts directory.

Within a layout, you can use the `yield` method to place the view body.  For instance, here's a dead simple application.html.ejs file:

```html
<html>
  <head>
  </head>
  <body>
    <%- yield() %>
  </body>
</html>
```

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
