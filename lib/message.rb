class Message

  attr_reader :id, :push_uri, :payload, :secret

  def initialize(id:, push_uri:, payload:, secret:)
    @id = id
    @push_uri = push_uri
    @payload = payload
    @secret = secret
  end

  def deliver
    # post payload (with secret header) to push uri
    # on error, status='failed', save failure details, create new message
    # on success, status='succeeded', 
  end

  def cancel
    # status = canceled
  end

end
