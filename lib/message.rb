class Message

  attr_reader :id, :push_uri, :payload, :secret
  attr_reader :event_id, :subscription_id

  def initialize(id:, push_uri:, payload:, secret:, event_id:, subscription_id:)
    @id = id
    @push_uri = push_uri
    @payload = payload
    @secret = secret

    @event_id = event_id
    @subscription_id = subscription_id
  end

  def retry_record timestamp
    {
      :event_id => event_id,
      :subscription_id => subscription_id,
      :status => 'pending',
      :retry_at => timestamp
    }
  end

end
