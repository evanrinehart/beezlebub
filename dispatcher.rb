require 'sequel'
require 'dispatcher'
require 'db'

$stdout.sync = true
$stderr.sync = true

puts 'Dispatcher online'
PID_PATH = '/var/tmp/dispatcher.pid'

pid = Process.pid
IO.write(PID_PATH, pid)

db = db_connect

at_exit do
  File.unlink PID_PATH
  db.disconnect
end

Dispatcher.new(db).run # never returns
