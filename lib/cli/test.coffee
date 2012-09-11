Path = require '../path'

exports.description = 'Run tests'

exports.method = ->
  Mocha = require 'mocha'
  mocha = new Mocha()

  require 'should'
  mocha.reporter('spec')
  mocha.files = Caboose.path.test.ls_sync(recursive: true, extensions: ['js', 'coffee']).map (f) -> f.path
  mocha.run(process.exit)
