require 'matterhorn/endpoint_api/version'

module Matterhorn
  module EndpointApi
    def self.info
      "Matterhorn Endpoint API Version #{Matterhorn::EndpointApi::VERSION}"
    end
  end
end
