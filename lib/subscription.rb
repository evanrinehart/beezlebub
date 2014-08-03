require 'sequel'
require 'app'

class Subscription < Sequel::Model

  many_to_one :app

end
