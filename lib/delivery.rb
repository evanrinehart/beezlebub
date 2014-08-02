require 'event'
require 'subscription'

class Delivery

  attr_reader :id, :event, :subscription, :delivered_at, :failure

  def initialize(id:, event:, subscription:, delivered_at:, failure:)
    @id = id
    @event = event
    @subscription = subscription
    @delivered_at = delivered_at
    @failure = failure
  end

end
