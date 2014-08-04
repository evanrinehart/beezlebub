require 'subscription'
require 'event'

class Message < Sequel::Model

  many_to_one :subscription
  many_to_one :event

  def new_retry timestamp
    Message.new(
      :event_id => event_id,
      :subscription_id => subscription_id,
      :status => 'pending',
      :retry_at => timestamp
    )
  end

  def app
    subscription.app
  end

  def push_uri
    subscription.push_uri
  end

  def content_type
    event.content_type
  end

  def payload
    event.payload
  end

  def secret
    subscription.app.secret
  end

end
