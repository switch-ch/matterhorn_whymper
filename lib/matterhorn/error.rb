# =================================================================================== Matterhorn ===

module Matterhorn


  # ====================================================================== several error classes ===

  class Error < StandardError
  end
  

  class HttpGeneralError < Matterhorn::Error

    attr_reader :request, :response, :code

    def initialize(request, response)
      @request  = request
      @response = response
      @code     = response.code.to_i
    end

  end


  class HttpClientError < Matterhorn::HttpGeneralError
  end

  
  class HttpServerError < Matterhorn::HttpGeneralError
  end


end # --------------------------------------------------------------------------- end Matterhorn ---
