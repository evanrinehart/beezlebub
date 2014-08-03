require 'sequel'
require 'db' # connects to database
require 'dispatcher'
require 'sender'

$stdout.sync = true
$stderr.sync = true

puts 'Dispatcher online'
PID_PATH = '/var/tmp/dispatcher.pid'

pid = Process.pid
IO.write(PID_PATH, pid)

at_exit do
  $database.disconnect
  File.unlink PID_PATH
end

# never returns
Dispatcher.new(
  database: $database,
  sender: Sender.new
).run
