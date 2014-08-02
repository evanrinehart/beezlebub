require 'sequel'
require 'dispatcher'
require 'db'

db = db_connect

at_exit do
  db.disconnect
end

Dispatcher.new(db).run # never returns
