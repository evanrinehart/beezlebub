require 'sequel'

class Event < Sequel::Model

  many_to_one :app
  
end
