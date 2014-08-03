require 'sequel'

puts 'CONNECTING'
$database = Sequel.connect ENV['DATABASE_URL']
Sequel::Model.db = $database
