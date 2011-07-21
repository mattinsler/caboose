service = require './lib/server'
mongo = require './lib/mongo'

exports.createServer = service.createServer
exports.connect = -> mongo.connect.apply mongo, arguments
exports.Model = mongo.Model

exports.start = require('./caboose').start