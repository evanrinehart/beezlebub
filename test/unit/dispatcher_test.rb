require 'minitest/autorun'
require 'factories'
require 'db'
require 'dispatcher'

class DispatcherTest < Minitest::Test

  def setup
    $database.run('truncate apps')
    $database.run('truncate messages')
    $database.run('truncate subscriptions')
    $database.run('truncate events')
    @app1 = FactoryGirl.create :app,
      :name => 'pokr_volcano',
      :secret => "ABCDEF!@#"
    @app2 = FactoryGirl.create :app,
      :name => 'black_hole',
      :secret => "1234"
    @event = FactoryGirl.create :event, :app_id => @app1.id
    @subscription = FactoryGirl.create :subscription, :app_id => @app2.id
    @message = FactoryGirl.create :message,
      :subscription_id => @subscription.id,
      :event_id => @event.id

    @dispatcher = Dispatcher.new(
      database: $database,
      sender: Sender.new(test: true)
    )
  end

  def test_what_to_do
    @dispatcher.what_to_do
  end

  def test_attempt_to_send
    @dispatcher.attempt_delivery @message
  end

end
