class HTTPSimple::ResponseException

  def failure_report
    %Q{#{self.class}
message: #{self.message}
status: #{self.report[:status]}
request_uri: #{self.report[:uri]}
response_body:
#{self.report[:response_body]}
}
  end

end
