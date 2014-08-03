require 'factory_girl'

Dir['test/factories/*.rb'].each do |path|
  require "./#{path}"
end
