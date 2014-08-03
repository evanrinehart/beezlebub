require 'sinatra'
require 'sinatra/sequel'
require 'json'

before do
  content_type 'application/json'
end

get '/' do
  pid = IO.read('/var/tmp/dispatcher.pid')
  puts "pid = #{pid}"
  Process.kill 'ALRM', pid
  JSON.pretty_generate database[:messages].all
end

post '/events' do
  # verify secret
  # validate event
  # compute messages from event name
  # insert event and messages
  # return event id
end
