require 'sequel'

class Event < Sequel::Model

  many_to_one :app
  one_to_many :messages
  
end
