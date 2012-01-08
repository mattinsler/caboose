util = Caboose.util
logger = Caboose.logger

underscorize = (name) ->
  Caboose.registry.split(name).map((s) -> s.toLowerCase()).join('_')

capitalize = (name) ->
  Caboose.registry.split(name).map((s) -> s[0].toUpperCase() + s.substr(1).toLowerCase()).join('')

Caboose.cli.namespace 'model', (switchback) ->
  switchback
  .describe('caboose-model commands')
  .command('new', {
    description: 'Create a new model'
    method: (model_name) ->
      return logger.error('Must provide a model name') unless model_name?

      logger.title "Creating new model #{capitalize(model_name)}"
      
      util.create_file(
        Caboose.path.models.join("#{underscorize(model_name)}.coffee"),
        "class #{capitalize(model_name)} extends Model\n  store_in '#{underscorize(model_name)}'\n"
      )
  })
