fs = require 'fs'
path = require 'path'
switchback = require 'switchback'

base = __dirname
for file in fs.readdirSync base
  options = require path.join(base, file)
  switchback.command /^([^.]+)/.exec(path.basename(file))[0], options if options.method

module.exports = switchback

# var sys = require('sys')
#   , caboose = require('caboose');
# 
# function usage() {
#   sys.puts([
#     'usage: caboose',
#     '',
#     'commands:',
#     '  start          Start server',
#     '  test script    Test with script in test directory',
#     '  run script     Run script',
#     '  console        Open a javascript console with your app loaded',
#     '  routes         Print out routes',
#     'options:',
#     '  -h, --help     Show the help'
#   ].join('\n'));
#   process.exit(1);
# }
# 
# function error(err) {
#   sys.puts('ERROR: ' + err.stack);
#   usage();
# }
# 
# var argv = require('optimist').argv;
# if (argv.h || argv.help || argv._.length === 0) {
#   usage();
# }
# 
# var command = argv._.shift();
# caboose.cli
# 
# if (!caboose[command]) {
#   usage();
# }
# 
# caboose[command].call(caboose, process.cwd(), argv);