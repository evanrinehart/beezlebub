class AttemptToSendMessages
  attr_reader :messages
  def initialize messages
    @messages = messages
  end
end

class TryAgainAt
  attr_reader :timestamp
  def initialize timestamp
    @timestamp = timestamp
  end
end

class NothingToDo
end

