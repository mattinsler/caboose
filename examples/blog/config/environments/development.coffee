module.exports = (config, next) ->
  config.model = {
    host: 'localhost'
    port: 27017
    database: 'caboose_blog_dev'
  }
  next()
