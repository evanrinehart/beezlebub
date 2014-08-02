require 'sequel'

def db_connect
  Sequel.connect ENV['DB_URI']
end
