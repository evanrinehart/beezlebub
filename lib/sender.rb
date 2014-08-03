require 'http_simple'
require 'exception'
require 'message'

class Sender

  class DeliveryFailed < StandardError; end

  def initialize(test:false, debug:false, mode: :success)
    @test = test
    @debug = debug
    @mode = mode
  end

  def attempt_send message
    if @test && @mode == :success
      return nil
    end

    if @test && @mode == :failure
      raise HTTPSimple::NetworkException, "send failed: test mode"
    end

    begin
      puts "posting message #{message.id}" if @debug
      response = HTTPSimple::post(
        message.push_uri,
        body: message.payload,
        headers: {
          'Content-Type' => message.content_type,
          'X-Event-Secret' => message.secret
        }
      )
      puts "response = #{response}" if @debug
      nil
    rescue HTTPSimple::ResponseException => e
      raise DeliveryFailed, e.failure_report
    rescue HTTPSimple::NetworkException => e
      raise DeliveryFailed, "#{e.class} #{e.message}"
    end
  end

end
