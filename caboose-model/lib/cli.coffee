require 'colors'

underscorize = (name) ->
  Caboose.registry.split(name).map((s) -> s.toLowerCase()).join('_')

capitalize = (name) ->
  Caboose.registry.split(name).map((s) -> s[0].toUpperCase() + s.substr(1).toLowerCase()).join('')

mkdirp = (path) ->
  if path.exists_sync()
    console.log '          ' + 'exists'.grey + ' ' + path
  else
    dirs = [path]
    until (path = path.join('..')).exists_sync()
      dirs.push path
    while (d = dirs.shift())
      console.log '          ' + 'mkdir'.blue + '  ' + d
      d.mkdir_sync(0755)

module.exports = {
  install: {
    description: 'Install the caboose-model plugin'
    method: ->
      console.log '[CABOOSE] ' + 'install'.green + ' caboose-model'
      
      config_file = Caboose.path.config.join('caboose-model.json')
      if config_file.exists_sync()
        console.log '          ' + 'exists'.grey + ' ' + config_file
      else
        console.log '          ' + 'create'.green + ' ' + config_file
        config_file.write_file_sync JSON.stringify({host: 'localhost', port: 27017, database: Caboose.app.name}, null, 2), 'utf8'
      
      initializer_file = Caboose.path.config.join('initializers', 'caboose-model.coffee')
      if initializer_file.exists_sync()
        console.log '          ' + 'exists'.grey + ' ' + initializer_file
      else
        mkdirp(initializer_file.join('..'))
        console.log '          ' + 'create'.green + ' ' + initializer_file
        initializer_file.write_file_sync "require 'caboose-model'\n", 'utf8'
      
      unless Caboose.path.models.exists_sync()
        console.log '          ' + 'create'.green + ' ' + Caboose.path.models
        Caboose.path.models.mkdir_sync(0755)
      
      try
        package_file = Caboose.root.join('package.json')
        console.log '          ' + 'alter'.grey + ' ' + package_file
        package = JSON.parse(package_file.read_file_sync('utf8'))
        package.dependencies['caboose-model'] = require('../index').version.join('.')
        package_file.write_file_sync(JSON.stringify(package, null, 2), 'utf8')
      catch e
        console.log '          Could not read or alter package.json file.'.red
  }
  
  new: {
    description: 'Create a new model'
    method: (model_name) ->
      return console.log('Must provide a model name'.red) unless model_name?
      
      console.log '[CABOOSE] ' + 'create'.green + " model #{capitalize(model_name)}"
      mkdirp(Caboose.path.models)
      model_file = Caboose.path.models.join("#{underscorize(model_name)}.coffee")
      return (console.log '          ' + 'exists'.grey + ' ' + model_file) if model_file.exists_sync()
      console.log '          ' + 'create'.green + ' ' + model_file
      model_file.write_file_sync("class #{capitalize(model_name)} extends Model\n  store_in '#{underscorize(model_name)}'\n", 'utf8')
  }
}
