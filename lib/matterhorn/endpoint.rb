class Matterhorn::Endpoint

  # --- attributes -------------------------------------------------------------

  attr_reader :http_client

  # --- initialization ---------------------------------------------------------

  def self.open(endpoint)
    if endpoint.respond_to? 'to_s'
      endpoint = endpoint.to_s.capitalize
    else
      #TODO: error handling
    end
    endpoint = Object.const_get('Matterhorn').const_get('Endpoint').const_get(endpoint).new

    yield endpoint

    endpoint.close
  end  


  def initialize
    @http_client = Matterhorn::HttpClient.new(
      Matterhorn::EndpointApi.configuration.uri
    )
  end


  def close
    http_client.close
  end

end