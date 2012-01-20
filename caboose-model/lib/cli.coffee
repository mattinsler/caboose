util = Caboose.util
logger = Caboose.logger

underscorize = (name) ->
  Caboose.registry.split(name).map((s) -> s.toLowerCase()).join('_')

capitalize = (name) ->
  Caboose.registry.split(name).map((s) -> s[0].toUpperCase() + s.substr(1).toLowerCase()).join('')

Caboose.generators.add {
  name: 'model'
  describe: 'Create a new model'
  method: (model_name) ->
    return logger.error('Must provide a model name') unless model_name?

    logger.title "Creating new model #{capitalize(model_name)}"
    
    util.create_file(
      Caboose.path.models.join("#{underscorize(model_name)}.coffee"),
      """
        class #{capitalize(model_name)} extends Model
          store_in '#{underscorize(model_name)}'
        
      """
    )
}
