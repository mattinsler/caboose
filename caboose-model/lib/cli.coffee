require 'colors'

module.exports = {
  install: {
    description: ''
    method: ->
      console.log '[CABOOSE] ' + 'intall'.green + ' caboose-model'
      
      initializer_file = Caboose.path.config.join('initializers', 'caboose-model.coffee')
      if initializer_file.exists_sync()
        console.log '          ' + 'exists'.grey + ' ' + initializer_file
      else
        console.log '          ' + 'create'.green + ' ' + initializer_file
        initializer_file.join('..').mkdir_sync(0755) unless initializer_file.join('..').exists_sync()
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
}
