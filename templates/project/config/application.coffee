module.exports = (config, next) ->
  config.http =
    enabled: true
    port: process.env.PORT || 3000

  next()
