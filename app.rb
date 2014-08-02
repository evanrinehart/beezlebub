require 'sinatra'

pid = Process.spawn("bundle exec ruby -Ilib dispatcher.rb", :out => :out, :err => :err)
puts "SPAWNED #{pid}"

get '/' do
  Process.kill 'ALRM', pid
  puts "wheres my std out?"
  "hello world"
end
