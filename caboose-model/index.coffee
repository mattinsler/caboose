if global['caboose-model']?
  exports[k] = v for k, v of global['caboose-model']
  return

_ = require 'underscore'

exports.version = [0, 1, 1]

exports.cli = require './lib/cli'
Builder = exports.Builder = require './lib/builder'
Compiler = exports.Compiler = require './lib/model_compiler'
Connection = exports.Connection = require './lib/connection'
Model = exports.Model = require './lib/model'
Query = exports.Query = require './lib/query'

objs = {
  Builder: Builder
  Compiler: Compiler
  Connection: Connection
  Model: Model
  Query: Query
}

if Caboose?
  Caboose.registry.register 'model', {
    get: (parsed_name) ->
      name = parsed_name.join('_')
      try
        files = Caboose.path.models.readdir_sync()
        model_file = _(files).find((f) -> f.basename is name)
        return null unless model_file?
        return Compiler.compile(model_file) if model_file.extension is 'coffee'
        model_file.require()
      catch e
        console.error e.stack
  }

exports.connection = null

exports.configure = (config) ->
  exports.config = config
  this

exports.add_plugin = (name) ->
  require(name) objs
  this

exports.create = (name) ->
  new objs.Builder name

if Caboose?.app?.config?.model?
  exports.configure Caboose.app.config.model

global['caboose-model'] = exports
