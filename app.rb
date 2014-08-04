require 'sinatra'
require 'json'

require 'signaler'

require 'db'
require 'app'
require 'message'

signaler = Signaler.new

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

before do
  @nav = [
    '/a/events',
    '/a/messages',
    '/a/apps',
    '/a/subscriptions'
  ]
end

before '/a/*' do
  # check cookie
end

helpers do
  def show_time timestamp
    if timestamp
      if timestamp.to_date == Date.today
        timestamp.strftime('%H:%M:%S')
      else
        timestamp.strftime('%Y-%m-%d')
      end
    else
      ''
    end
  end
end


post '/events' do
  secret = params[:secret]
  name = params[:name]
  version = params[:version] || 0
  payload = params[:payload]
  payload_content_type = params[:content_type]

  app = $database[:apps][:secret => secret]

  halt 403 if app.nil?
  halt 400, "bad name\n" if name.nil? || name.empty? || !name.is_a?(String)
  halt 400, "bad version\n" if !version.is_a?(Integer)
  halt 400, "bad payload\n" if !payload.is_a?(String)
  halt 400, "bad content type\n" unless payload_content_type.nil? || payload_content_type.is_a?(String)

  event, count = $database.transaction do
    event = Event.create(
      :name => name,
      :version => version,
      :app_id => app[:id],
      :payload => payload
    )
      
    subscriptions = Subscription.where(:event_name => name)
    new_messages = subscriptions.map do |row|
      {
        :event_id => event.id,
        :subscription_id => row[:id],
        :status => 'pending'
      }
    end
    $database[:messages].multi_insert new_messages

    [event, subscriptions.count]
  end

  signaler.signal # wake up the dispatcher if possible

  content_type 'application/json'
  JSON.pretty_generate(
    :event_id => event.id,
    :message_count => count
  )
end

get '/a/events' do
  @header = 'events'
  @headers = ['id', 'name', 'from', 'messages']
  @rows = Event.all.map do |event|
    [
      event.id,
      event.name,
      event.app.name,
      "/a/events/#{event.id}/messages"
    ]
  end
  erb :data
end

get '/a/messages' do
  @messages = Message
    .eager(:subscription, :event)
    .order(:status)
  erb :messages
end

delete '/a/messages/:id' do
  message = Message[params[:id]]
  if message.status != 'pending'
    halt 400, "don't try to cancel message #{message.id} currently (#{message.status})"
  end
  message.update :status => 'canceled'
  redirect '/a/messages'
end

get '/a/subscriptions' do
  @header = 'subscriptions'
  @headers = ['id', 'subscriber', 'event', 'push_uri', 'note']
  @rows = Subscription.all.map do |sub|
    [
      sub.id,
      sub.app.name,
      sub.event_name,
      sub.push_uri,
      sub.note
    ]
  end
  erb :data
end

get '/a/apps' do
  @header = 'apps'
  @headers = ['id', 'name', 'secret']
  @rows = App.all.map do |app|
    [
      app.id,
      app.name,
      app.secret
    ]
  end
  erb :data
end

