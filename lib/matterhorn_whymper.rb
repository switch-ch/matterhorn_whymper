# Define Matterhorn Namespace
#
module Matterhorn
end


require 'matterhorn_whymper/version'
require 'matterhorn/acl'
require 'matterhorn/dublin_core'
require 'matterhorn/endpoint'
require 'matterhorn/endpoint/event'
require 'matterhorn/endpoint/ingest'
require 'matterhorn/endpoint/series'
require 'matterhorn/endpoint/workflow'
require 'matterhorn/error'
require 'matterhorn/http_client'
require 'matterhorn/java_properties'
require 'matterhorn/media_package'
require 'matterhorn/smil'
require 'matterhorn/workflow_instance'


# ============================================================================ MatterhornWhymper ===

module MatterhornWhymper


  # --------------------------------------------------------------------------------- attributes --- 

  class << self
    attr_accessor :configuration, :logger
  end
 

  # ----------------------------------------------------------------------------------- methodes ---

  def self.info
    "Ruby wrapper against the Matterhorn Endpoint API. Version #{MatterhornWhymper::VERSION}"
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
 


  # =========================================================== MatterhornWhymper::Configuration ===

  class Configuration

    # --------------------------------------------------------------------------------- methodes ---

    def initialize
      @mhw_config = {}
    end

    def add_matterhorn_instance(name = 'default')
      @mhw_config[name.to_sym] = {}
    end

    def add_endpoint(options, mh_i = 'default')
      @mhw_config[mh_i.to_sym][:endpoint] = validate_options(options)
    end

    def add_api(options, mh_i = 'default')
      @mhw_config[mh_i.to_sym][:api] = validate_options(options)
    end

    def set_default_matterhorn_instance(mh_i)
      unless @mhw_config[mh_i.to_sym].nil?
        @mhw_config[:default] = @mhw_config[mh_i.to_sym]
      end
    end
    

    def endpoint(mh_i = :default)
      @mhw_config[mh_i][:endpoint]
    end

    def api(mh_i = :default)
      @mhw_config[mh_i][:api]
    end

    
    # -------------------------------------------------------------------------- private section ---
    private

    def validate_options(opt)
      valid_keys = [:protocol, :domain, :user, :password, :auth_mode,
                    :http_timeout, :ssl_dont_verify_cert, :multi_tenant]
      options = {
        :protocol  => 'http',
        :domain    => 'example.org',
        :user      => 'admin',
        :password  => '',
        :auth_mode => 'basic',
        :http_timeout         => nil,
        :ssl_dont_verify_cert => false,
        :multi_tenant => true
      }
      opt.each do |key, value|
        if valid_keys.include? key.to_sym
          options[key.to_sym] = value
        end
      end
      options
    end


  end # --------------------------------------------------- end MatterhornWhymper::Configuration ---


end # -------------------------------------------------------------------- end MatterhornWhymper ---
