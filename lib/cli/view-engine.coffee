util = Caboose.util
logger = Caboose.logger
SUPPORTED_ENGINES = ['eco', 'ejs', 'haml', 'haml-coffee', 'jade', 'jazz', 'jqtpl', 'liquor', 'swig', 'whiskers', 'kernel', 'hogan', 'dust']

exports.description = 'Install a view engine'

actions = {
  list: ->
    logger.title 'Installed View Engines:'
    engines = Object.keys(util.read_package().dependencies).filter (k) -> k in SUPPORTED_ENGINES
    logger.message("  - #{e}", 0) for e in engines

  install: (engine) ->
    if engine not in SUPPORTED_ENGINES
      logger.error 'You must specify a view engine to install'
      logger.message 'Supported Engines:', 0
      logger.message("  - #{e}", 0) for e in SUPPORTED_ENGINES
      return
    util.npm_install engine

  uninstall: (engine) ->
    return logger.error('You must specify a view engine to install') if engine not in SUPPORTED_ENGINES
    util.remove_dependency_from_package engine
}

exports.method = (action, args...) ->
  return actions.list() unless action?
  return logger.error 'Usage: caboose view-engine (list|install|uninstall)' unless actions[action]?
  actions[action] args...
