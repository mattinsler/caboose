Type = require('caboose').Model.Type

exports.Int32 = class Int32 extends Type
  @name: 'Int32'
  
  constructor: (spec, options) ->
    super spec, options