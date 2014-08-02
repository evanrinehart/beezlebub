require './app'

$stdout.sync = true
$stderr.sync = true

run Sinatra::Application
