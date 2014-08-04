require 'alarm'
require 'sequel'
require 'instruction'
require 'bug'
require 'http_simple'
require 'message'
require 'exception'
require 'sender'

puts 'loading'
class Dispatcher

  include Alarm
  # run
  # set_interruptible_alarm_for

  if ENV['RETRY_TIME'] !~ /\A\d+\z/
    raise "set env var RETRY_TIME to an integer"
  end
  RETRY_TIME = ENV['RETRY_TIME'].to_i

  attr_reader :database

  class DeliveryFailed < StandardError; end

  def initialize(database:, sender:, debug:false)
    @database = database
    @sender = sender
    @debug = debug
  end

  def on_alarm
    puts 'ALARM!'
    loop do
      instruction = what_to_do
      case instruction
        when AttemptToSendMessages 
  puts "attempt to send #{instruction.messages.count} messages"
          instruction.messages.each do |message|
            attempt_delivery message
          end
        when TryAgainAt
  puts "try again at #{instruction.timestamp}"
          set_interruptible_alarm_for instruction.timestamp
          break
        when NothingToDo
  puts "do nothing"
          # do nothing
          break
        else raise Bug, "what_to_do = #{instruction.inspect} ??"
      end
    end
    nil
  end

  def what_to_do
    database.transaction(
      :isolation => :serializable,
      :retry_on => [Sequel::SerializationFailure]
    ) do

      messages = Message
        .eager(:subscription, :event => :app)
        .where(:status => 'pending')
        .where('retry_at is null OR retry_at < now()')

      if messages.count > 0
        return AttemptToSendMessages.new(messages)
      end

      messages = Message
        .eager(:subscription, :event => :app)
        .where(:status => 'pending')
        .where('retry_at is not null')
        .order(:retry_at)

      if messages.count > 0
        return TryAgainAt.new(messages.first.retry_at + 5)
      else
        return NothingToDo.new
      end
    end
  end

  def attempt_delivery message
    database.transaction do
      begin
        @sender.attempt_send message
      rescue Sender::DeliveryFailed => e
        retry_at = Time.now + RETRY_TIME

        message.update(
          :delivered_at => Sequel::CURRENT_TIMESTAMP,
          :status => 'failed',
          :failure => e.message
        )

        message.new_retry(retry_at).save

        'failure'
      else
        message.update(
          :delivered_at => Sequel::CURRENT_TIMESTAMP,
          :status => 'delivered'
        )

        'success'
      end
    end
  end

end

