Type = require('caboose').Model.Type

exports.String = class String extends Type
  @name: 'String'
  
  constructor: (spec, options) ->
    super spec, options