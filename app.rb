require 'sinatra'
require 'sinatra/sequel'
require 'json'

require './lib/signaler'

signaler = Signaler.new

before do
  content_type 'application/json'
end

before do
  if request.request_method == 'POST' && request.content_type == 'application/json'
    json = request.body.read
    begin
      data = JSON.parse(json)
    rescue JSON::ParserError
      halt 400, "bad json\n"
    end
    params.merge! data
  end
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
  payload_content_type = params[:content_type]

  app = database[:apps][:secret => secret]

  halt 403 if app.nil?
  halt 400, "bad name\n" if name.nil? || name.empty? || !name.is_a?(String)
  halt 400, "bad version\n" if !version.is_a?(Integer)
  halt 400, "bad payload\n" if !payload.is_a?(String)
  halt 400, "bad content type\n" unless payload_content_type.nil? || payload_content_type.is_a?(String)

  event_id, count = database.transaction do
    event_id = database[:events].insert(
      :name => name,
      :version => version,
      :app_id => app[:id],
      :payload => payload
    )
      
    subscriptions = database[:subscriptions].where(:event_name => name)
    new_messages = subscriptions.map do |row|
      {
        :event_id => event_id,
        :subscription_id => row[:id],
        :status => 'pending'
      }
    end
    database[:messages].multi_insert new_messages

    [event_id, subscriptions.count]
  end

  signaler.signal # wake up the dispatcher if possible

  JSON.pretty_generate(
    :event_id => event_id,
    :message_count => count
  )
end

