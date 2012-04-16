# {
#   code: 
#   content: (Error | 'html' | string)
#   controller:
#   view:
#   options: {
#     layout: 
#   }
# }

module.exports = (opts, callback) ->
  process.nextTick ->
    callback(null, JSON.stringify(opts.options.json))
