require 'colors'

module.exports = {
  install: {
    description: ''
    method: ->
      console.log '[CABOOSE] ' + 'intall'.green + ' caboose-model'
      
      initializer_file = Caboose.path.config.join('initializers', 'caboose-model.coffee')
      if initializer_file.exists_sync()
        console.log '          ' + 'exists'.grey + ' ' + initializer_file
        return
      
      console.log '          ' + 'create'.green + ' ' + initializer_file
      initializer_file.write_file_sync "require 'caboose-model'\n", 'utf8'
      
      # should probably edit package.json here... or at least check it
      console.log '          Be sure to add caboose-model 0.1.x to your package.json file'.blue
  }
}
