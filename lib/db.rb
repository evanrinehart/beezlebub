require 'sequel'

def db_connect
  Sequel.connect ENV['DATABASE_URL']
end
