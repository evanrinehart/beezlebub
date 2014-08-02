require 'sinatra'

pid = Process.spawn("ruby -Ilib dispatcher.rb", :out => :out, :err => :err)
puts "SPAWNED #{pid}"

get '/' do
  "hello world"
end
