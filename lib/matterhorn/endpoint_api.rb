require 'matterhorn/endpoint_api/version'
require 'matterhorn/endpoint'
require 'matterhorn/endpoint/ingest'
require 'matterhorn/endpoint/workflow'
require 'matterhorn/http_client'
require 'matterhorn/media_package'
require 'matterhorn/error'

module Matterhorn
  module EndpointApi

    def self.info
      "Matterhorn Endpoint API Version #{Matterhorn::EndpointApi::VERSION}"
    end

    class << self
      attr_accessor :configuration, :logger
    end

    def self.configure
      self.configuration ||= Configuration.new
      if defined?(Rails)
        self.logger = Rails.logger
      else
        require 'logger'
        self.logger = Logger.new(STDOUT)
      end
      puts "logger = #{@logger.inspect}"
      yield(configuration)
    end

    class Configuration
      attr_accessor :uri
    end

  end
end
