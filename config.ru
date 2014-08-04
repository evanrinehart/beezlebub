$LOAD_PATH.unshift('lib')
require './app'

$stdout.sync = true
$stderr.sync = true

run Sinatra::Application
