require 'sinatra'
require 'sinatra/sequel'
require 'json'

require './lib/signaler'

signaler = Signaler.new

before do
  content_type 'application/json'
end

get '/' do
  signaler.signal # wake up the dispatcher if possible
  JSON.pretty_generate database[:messages].all
end

post '/events' do
  secret = params[:secret]
  name = params[:name]
  version = params[:version] || 0
  payload = params[:payload]

  app = database[:apps][:secret => secret]
  halt 403 if app.nil?

  halt 400, 'bad name' if name.nil? || name.empty? || !name.is_a?(String)
  halt 400, 'bad version' if !version.is_a?(Integer)
  halt 400, 'bad payload' if !payload.is_a?(String)

  event, count = database.transaction do
    event = database[:events].insert(
      :name => name,
      :version => version,
      :app_id => app[:id],
      :payload => payload
    )
      
    subscriptions = database[:subscriptions].where(:name => name)
    subscriptions.each do |row|
      database[:messages].insert(
        :event_id => event[:id],
        :subscription_id => row[:id],
        :status => 'pending'
      )
    end

    [event, subscriptions.count]
  end

  signaler.signal # wake up the dispatcher if possible

  JSON.pretty_generate(
    :event_id => event[:id],
    :message_count => count
  )
end

