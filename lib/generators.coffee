logger = Caboose.logger

class Generators
  constructor: ->
    @generators = {}
  
  add: (opts) ->
    throw new Error('Generators require a name') unless opts.name?
    throw new Error('Generators require a method') unless opts.method?
    throw new Error("A generator already exists for #{opts.name}") if @generators[opts.name]?
    
    @generators[opts.name] = opts
  
  generate: (type, args...) ->
    return logger.error("No generator for type #{type}") unless @generators[type]?
    @generators[type].method(args...)
  
  supported_types: ->
    Object.keys(@generators)
  
module.exports = new Generators()
