var fs = require('fs')
  , path = require('path')
  , parse = require('url').parse
  , express_static = require('express').static;

exports = module.exports = function static(root, options) {
  options = options || {};
  // root required
  if (!root) throw new Error('static() root path required');
  if (!options.tmp) throw new Error('static() options.tmp path required');
  options.root = root;

  return function static(req, res, next) {
    options.path = req.url;
    options.getOnly = true;
    options.callback = err_callback(req, res, next, options);
    express_static.send(req, res, next, options);
  };
};

function mkdirSync(dir_path, mode) {
  if (path.existsSync(dir_path)) {return;}
  var parts = dir_path.split('/');
  for (var x = 1; x < parts.length; ++x) {
    var tmp = parts.slice(0, x + 1).join('/');
    if (!path.existsSync(tmp)) {
      fs.mkdirSync(tmp, mode);
    }
  }
}

var err_callback = function(req, res, next, options) {
  return function err_callback(err) {
    if (!err) {
      console.log('Called with no error');
      if (next) {return next(err);}
    }
    function handle_error() {
      process.nextTick(function() {
        'ENOENT' == err.code ? next() : next(err);
      });
    }
    function send_file() {
      delete options.callback;
      options.root = path.join(options.tmp, 'static/coffee');
      process.nextTick(function() {
        express_static.send(req, res, next, options);
      });
    }
    
    if ('ENOENT' != err.code) {
      return handle_error();
    }
    
    var base_path = decodeURIComponent(parse(options.path).pathname);
    if ('.js' !== path.extname(base_path)) {
      return handle_error();
    }
    
    // "hidden" file
    if (!options.hidden && '.' == path.basename(base_path)[0]) {return next();}
    var file_path = path.normalize(path.join(options.root, base_path));
    var tmp_path = path.join(options.tmp, 'static/coffee', base_path);

    if (path.existsSync(tmp_path)) {
      return send_file();
    }
    
    var coffee_path = file_path.substring(0, file_path.length - 3) + '.coffee';
    if (!path.existsSync(coffee_path)) {
      return handle_error();
    }
    
    if (path.existsSync(coffee_path)) {
      fs.readFile(coffee_path, 'utf8', function(coffee_err, coffee_code) {
        if (coffee_err) {
          return handle_error();
        }
        var coffee = require('coffee-script');
        var js_code = coffee.compile(coffee_code, {filename: coffee_path});
        mkdirSync(path.dirname(tmp_path), '0777');
        fs.writeFile(tmp_path, js_code, 'utf8', function(write_err) {
          if (write_err) {
            console.error(write_err.stack);
            return handle_error();
          }
          return send_file();
        });
      });
    }
  };
};