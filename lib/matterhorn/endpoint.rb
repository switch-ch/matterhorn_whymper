# =================================================================================== Matterhorn ===

module Matterhorn


  # ======================================================================= Matterhorn::Endpoint ===

  class Endpoint

    # ------------------------------------------------------------------------------- attributes ---
  
    attr_reader :http_client
  

    # --------------------------------------------------------------------------- initialization ---
  
    def self.create(endpoint)
      if endpoint.respond_to? 'to_s'
        endpoint = endpoint.to_s.capitalize
      else
        raise(Matterhorn::Error, "Matterhorn::Endpoint::open | " +
                                 "#{endpoint.inspect} does not respond to 'to_s'")
      end
      endpoint = Object.const_get('Matterhorn').const_get('Endpoint').const_get(endpoint).new
      if endpoint.nil? || !endpoint.kind_of?(Matterhorn::Endpoint)
        raise(Matterhorn::Error, "Matterhorn::Endpoint::open | " +
                                 "#{endpoint ? endpoint.class.name : 'nil'} is not a sub class " +
                                 "of 'Matterhorn::Endpoint'!")
      end
      endpoint
    end


    def self.open(endpoint)
      endpoint = create(endpoint)
      begin
        yield endpoint
      ensure
        endpoint.close
      end
    end  
  
  
    def initialize
      @http_client = Matterhorn::HttpClient.new(
        MatterhornWhymper.configuration.uri,
        MatterhornWhymper.configuration.http_timeout,
        MatterhornWhymper.configuration.ssl_dont_verify_cert
      )
    end
  
  
    # --------------------------------------------------------------------------------- methodes ---

    def close
      http_client.close
    end


  end # --------------------------------------------------------------- end Matterhorn::Endpoint ---


end # --------------------------------------------------------------------------- end Matterhorn ---
