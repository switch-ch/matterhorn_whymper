# ====================================================================== several error classes ===

class Matterhorn::Error < StandardError
  def self.format_message(msg, ex)
    "#{msg}\n" +
    "#{ex.class.name}: #{ex.to_s}\n    backtrace:\n    #{ex.backtrace.join("\n    ")}"
  end
end


class Matterhorn::HttpGeneralError < Matterhorn::Error

  attr_reader :request, :response, :code

  def initialize(request, response)
    @request  = request
    @response = response
    @code     = response.code.to_i
  end

end


class Matterhorn::HttpClientError < Matterhorn::HttpGeneralError
end


class Matterhorn::HttpServerError < Matterhorn::HttpGeneralError
end
