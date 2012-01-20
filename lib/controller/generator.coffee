_ = require 'underscore'
util = Caboose.util
logger = Caboose.logger

underscorize = (name) ->
  Caboose.registry.split(name).map((s) -> s.toLowerCase()).join('_')

capitalize = (name) ->
  Caboose.registry.split(name).map((s) -> s[0].toUpperCase() + s.substr(1).toLowerCase()).join('')

Caboose.generators.add {
  name: 'controller'
  describe: 'Generate a new controller'
  method: (name) ->
    return logger.error('Must provide a controller name') unless name?

    caps = capitalize(name)
    caps += 'Controller' unless /Controller$/.test(caps)
    under = underscorize(caps)
    logger.title "Creating new controller #{caps}"
    
    if _(Caboose.path.controllers.readdir_sync()).find((p) -> p.basename is 'application_controller')?
      file_content = """
        import 'ApplicationController'
        
        class #{caps} extends ApplicationController
          
      """
    else
      file_content = """
        class #{caps} extends Controller
          
      """
      
    util.create_file(
      Caboose.path.controllers.join("#{under}.coffee"),
      file_content
    )
    util.mkdir Caboose.path.views.join(under.split('_').slice(0, -1).join('_'))
}
