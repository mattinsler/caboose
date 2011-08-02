Type = require('caboose').Model.Type

exports.String = class String extends Type
  constructor: (spec, options) ->
    super(spec, options)