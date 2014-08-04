require 'sequel'

db_var = ENV['RACK_ENV'] == 'test' ?
  'TEST_DATABASE_URL' :
  'DATABASE_URL'
puts "CONNECTING TO DATABASE #{db_var}"
$database = Sequel.connect ENV[db_var]
Sequel::Model.db = $database
