Model = require 'caboose-model'

Model.configure {
  host: 'localhost'
  port: 27017
  database: 'test'
}
Model.add_plugin 'caboose-authentication'
