# Caboose

A [coffeescript](http://coffeescript.org)-happy [express](http://expressjs.com/)-based server-side MVC framework based on [Rails](http://rubyonrails.org/)

Check out the documentation at [caboosejs.com](http://www.caboosejs.com)

![caboose with coffee](http://www.caboosejs.com/images/caboose.jpg)

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

## Plugins

```bash
$ caboose plugin install [plugin name]
$ caboose plugin uninstall [plugin name]
```

### Plugin List

#### Model
[caboose-model](https://github.com/mattinsler/caboose/tree/master/caboose-model) - A mongodb model library for caboose
[caboose-model-delayed-render](https://github.com/mattinsler/caboose-model-delayed-render) - Delayed rendering for caboose-model
[caboose-model-before-action](https://github.com/mattinsler/caboose-model-before-action) - Adds pre-fab before_action helpers for caboose-model models to controllers

#### Auth
[caboose-authentication](https://github.com/mattinsler/caboose-authentication) - Caboose plugin to add authentication methods to caboose controllers

#### View
[caboose-bootstrap](https://github.com/mattinsler/caboose-bootstrap) - Twitter Bootstrap files integrated into caboose

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
