require 'alarm'
require 'sequel'
require 'instruction'
require 'bug'
require 'http_simple'

class Dispatcher

  include Alarm

  def initialize
    run
  end

  def on_alarm
    puts 'ALARM!'
    sleep 5
    puts 'going back to sleep'
    instruction = what_to_do
    case instruction
      when AttemptToSendMessages 
        instruction.messages.each do |message|
          attempt_delivery message
        end
      when TryAgainAt
        set_interruptible_alarm_for instruction.timestamp
      when NothingToDo
        # do nothing
      else raise Bug, "what_to_do = #{instruction.inspect} ??"
    end
  end

  def what_to_do
    NothingToDo.new
  end

  def attempt_delivery message
    # POST message.payload to message.push_uri using message.secret header
    # 200 is OK
    # anything else if a failure, schedule a retry
  end

end

Dispatcher.new # never returns
