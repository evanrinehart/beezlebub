class Event

  attr_reader :id, :name, :payload

  def initialize(id:,name:,payload:)
    @id = id
    @name = name
    @payload = payload
  end
  
end
