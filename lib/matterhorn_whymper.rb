require 'matterhorn_whymper/version'
require 'matterhorn/endpoint'
require 'matterhorn/endpoint/ingest'
require 'matterhorn/endpoint/workflow'
require 'matterhorn/http_client'
require 'matterhorn/media_package'
require 'matterhorn/error'

module MatterhornWhymper

  def self.info
    "Ruby wrapper against the Matterhorn Endpoint API. Version #{MatterhornWhymper::VERSION}"
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
