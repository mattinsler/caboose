Path = require './lib/path'

caboose_path = new Path(process.argv[1])
exec_path = new Path(process.argv[1])
try
  exec_path = exec_path.readlink_sync()
  exec_path = caboose_path.join('..', exec_path) if exec_path[0] is '.'
catch e

node_modules = [
  new Path().join('node_modules').path,
  new Path(__dirname).join('node_modules').path
]
console.log node_modules

node_path = {}
node_path[p] = true for p in process.env.NODE_PATH.split(':') if process.env.NODE_PATH?

unless node_path[node_modules[0]]? and node_path[node_modules[1]]?
  node_path[node_modules[0]] = true
  node_path[node_modules[1]] = true
  cmd = "NODE_PATH=#{Object.keys(node_path).join(':')} #{exec_path} #{process.argv.slice(2).join(' ')}"
  # console.log cmd
  require('kexec') cmd


Application = require './lib/application'

if not global.Caboose?
  Caboose = global.Caboose = {
    root: new Path()
    env: process.env.CABOOSE_ENV ? 'development'
  }
  Caboose.path = {
    app: Caboose.root.join('app')
    config: Caboose.root.join('config')
    lib: Caboose.root.join('lib')
    plugins: Caboose.root.join('plugins')
    public: Caboose.root.join('public')
    test: Caboose.root.join('test')
    tmp: Caboose.root.join('tmp')
  }
  Caboose.path.controllers = Caboose.path.app.join('controllers')
  Caboose.path.models = Caboose.path.app.join('models')
  Caboose.path.helpers = Caboose.path.app.join('helpers')
  Caboose.path.views = Caboose.path.app.join('views')

  Caboose.registry = require './lib/registry'
  package_file = Caboose.root.join('package.json')
  Caboose.app = new Application(JSON.parse(package_file.read_file_sync('utf8')).name) if package_file.exists_sync()

exports.cli = require './lib/cli'
exports.registry = global.Caboose.registry
exports.path = Path

exports.internal = {
  compiler: require('./lib/compiler')
}
