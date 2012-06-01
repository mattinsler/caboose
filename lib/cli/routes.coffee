cliff = require 'cliff'

exports.description = 'Display configured routes'

print_routes = (node, path = '', result = []) ->
  # path += '/' + (if node.segment? then node.segment else '')
  for method, routes of node.methods
    for r in routes
      result.push({
        Method: method
        Path: (if path is '' then '/' else path)
        Controller: r.route.options.controller
        Action: r.route.options.action
      })
  print_routes(child_node, path + '/:' + child_node.segment, result) for segment, child_node of node.params
  print_routes(child_node, path + '/' + child_node.segment, result) for segment, child_node of node.segments
  result

exports.method = ->
  console.log(cliff.stringifyObjectRows(
    print_routes(Caboose.app.router.root),
    ['Method', 'Path', 'Controller', 'Action']
  ))
