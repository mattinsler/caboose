util = Caboose.util
logger = Caboose.logger

exports.description = 'Generate an object'
exports.aliases = ['g', 'gen']

exports.method = (type, args...) ->
  Caboose.generators.generate(type, args...)
