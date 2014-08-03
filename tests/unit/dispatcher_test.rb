require 'test_helper'
require 'dispatcher'

class DispatcherTest < Minitest::Test

  def setup
    @fake_db = nil
    @dispatcher = Dispatcher.new(@fake_db)
  end

  def test_something
    assert true
  end

end
