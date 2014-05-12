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
    yield(configuration)    if block_given?
  end
 


  class Configuration

    attr_accessor :system_account_user, :system_account_password, :system_domain, :system_protocol

    def uri
      "#{system_protocol}://#{system_account_user}:#{system_account_password}@#{system_domain}"
    end


  end


end
