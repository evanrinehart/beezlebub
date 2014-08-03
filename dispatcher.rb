require 'sequel'
require 'dispatcher'
require 'db'

$stdout.sync = true
$stderr.sync = true

puts 'Dispatcher online'

pid = Process.pid
IO.write('/var/tmp/dispatcher.pid', pid)

db = db_connect

at_exit do
  db.disconnect
end

Dispatcher.new(db).run # never returns
