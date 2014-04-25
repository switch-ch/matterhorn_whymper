require 'matterhorn/endpoint_api/version'

module Matterhorn
  module EndpointApi
    def self.info
      puts "Matterhorn Endpoint API Version #{Matterhorn::EndpointApi::VERSION}"
    end
  end
end
