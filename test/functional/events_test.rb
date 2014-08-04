require 'minitest/autorun'
require 'rack/test'

require 'factories'

require_relative '../../app' #sinatra app

class EventsTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    $database.run 'truncate apps'
    @app = FactoryGirl.create :app
  end

  def test_event_post
    post "/events", "booya"
    assert last_response.status == 403

    post "/events", {:secret => @app.secret}
    assert last_response.status == 400

    count_before = $database[:events].where(:name => 'brew-coffee').count

    post "/events", {
      :secret => @app.secret,
      :name => "brew-coffee",
      :payload => "dark-roast"
    }
    assert last_response.status == 200

    count_after = $database[:events].where(:name => 'brew-coffee').count

    assert count_after == count_before+1
  end


end
