caboose = Caboose.exports
util = Caboose.util
logger = Caboose.logger

module.exports =
  'caboose-plugin': {
    install: (util, logger) ->
      logger.title 'Running installer for %PLUGIN-NAME%'
    
    initialize: ->
      logger.title 'Initializing %PLUGIN-NAME%'
  }
