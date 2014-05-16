# =================================================================================== Matterhorn ===

module Matterhorn


  # ====================================================================== several error classes ===

  class Error < StandardError
  end
  

  class HttpGeneralError < Matterhorn::Error

    attr_reader :code, :request, :response

    def initialize(message, request, response)
      @request = request
      @response = response
      @code = response.code.to_i
      super(message)
    end

  end


  class HttpClientError < Matterhorn::HttpGeneralError
  end

  
  class HttpServerError < Matterhorn::HttpGeneralError
  end


end # --------------------------------------------------------------------------- end Matterhorn ---
