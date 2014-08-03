require 'alarm'
require 'sequel'
require 'instruction'
require 'bug'
require 'http_simple'
require 'db'
require 'message'
require 'exception'

class Dispatcher

  include Alarm

  attr_reader :db

  class DeliveryFailed < StandardError; end

  def initialize db
    @db = db
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
  end

  def what_to_do
    db.transaction(
      :isolation => :serializable,
      :retry_on => [Sequel::SerializationFailure]
    ) do
      rows = db[:messages]
        .join(:events, :id => :event_id)
        .join(:subscriptions, :id => :messages__subscription_id)
        .join(:apps, :id => :app_id)
        .select(:messages__id, :payload, :apps__secret, :push_uri, :content_type)
        .select_append(:event_id, :subscription_id)
        .where(:status => 'pending')
        .where('retry_at is null OR retry_at < now()')

      if rows.count > 0
        messages = rows.map do |row|
          Message.new(
            id: row[:id],
            payload: row[:payload],
            push_uri: row[:push_uri],
            secret: row[:secret],
            event_id: row[:event_id],
            subscription_id: row[:subscription_id],
            content_type: row[:content_type]
          )
        end

        return AttemptToSendMessages.new(messages)
      end

      rows = db[:messages]
        .join(:events, :id => :event_id)
        .join(:subscriptions, :id => :messages__subscription_id)
        .join(:apps, :id => :app_id)
        .select(:messages__id, :payload, :apps__secret, :push_uri, :retry_at)
        .where(:status => 'pending')
        .where('retry_at is not null')
        .order(:retry_at)

      if rows.count > 0
        return TryAgainAt.new(rows.first[:retry_at]+5)
      else
        return NothingToDo.new
      end
    end
  end

  def attempt_delivery message
    db.transaction do
      record = db[:messages].where(:id => message.id)
      begin
        begin
puts "posting message #{message.id}"
          response = HTTPSimple::post(
            message.push_uri,
            body: message.payload,
            headers: {
              'Content-Type' => message.content_type,
              'X-Event-Secret' => message.secret
            }
          )
puts "response = #{response}"
        rescue HTTPSimple::ResponseException => e
          raise DeliveryFailed, e.failure_report
        rescue HTTPSimple::NetworkException => e
          raise DeliveryFailed, "#{e.class} #{e.message}"
        end
      rescue DeliveryFailed => e
puts "failure\n\n#{e.message}\n\n\n"
        retry_at = Time.now + 15
        record.update(
          :delivered_at => Sequel::CURRENT_TIMESTAMP,
          :status => 'failed',
          :failure => e.message
        )
        db[:messages].insert message.retry_record(retry_at)
        'failure'
      else
puts "success"
        record.update(
          :delivered_at => 'current_timestamp',
          :status => 'delivered'
        )
        'success'
      end
    end
  end

end

