class AttemptToSendMessages
  attr_reader :messages
  def initialize messages
    @messages = messages
  end
end

class TryAgainAt
  attr_reader :timestamp
  def intialize timestamp
    @timestamp = timestamp
  end
end

class NothingToDo
end

