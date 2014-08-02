class Subscription

  attr_reader :id, :app, :event_name, :push_uri, :secret

  def initialize(id:, app:, event_name: push_uri:, secret:)
    @id = id
    @app = app
    @event_name = event_name
    @push_uri = push_uri
    @secret = secret
  end

end
