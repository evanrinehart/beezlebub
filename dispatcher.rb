require 'sequel'
require 'dispatcher'
require 'db'

$stdout.sync = true
$stderr.sync = true

puts "DISPATCHER REPORTING"
puts "dispatcher booting up!"
db = db_connect

at_exit do
  db.disconnect
end

Dispatcher.new(db).run # never returns
