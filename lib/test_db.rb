require 'sequel'

$database = Sequel.connect ENV['TEST_DATABASE_URL']
Sequel::Model.db = $database

