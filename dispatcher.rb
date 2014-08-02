require 'sequel'
require 'dispatcher'
require 'db'

puts "DISPATCHER REPORTING"
puts "dispatcher booting up!"
db = db_connect

at_exit do
  db.disconnect
end

Dispatcher.new(db).run # never returns
