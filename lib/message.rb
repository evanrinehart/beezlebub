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

  def pending?
    status == 'pending'
  end

  def failed?
    status == 'failed'
  end

  def canceled?
    status == 'canceled'
  end

  def delivered?
    status == 'delivered'
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

  def header
%Q{message #{id}
event: #{event.name}
from: #{event.app.name}
to: #{subscription.app.name}
status: #{status}
delivered_at: #{delivered_at || '(not yet)'}
retry_at: #{retry_at || '(never)'}
push_uri: #{push_uri}
payload: #{payload}
}
  end

end
