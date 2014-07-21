require 'bundler/setup'
require 'yaml'

Bundler.setup

require 'matterhorn_whymper'
require 'webmock/rspec'

require 'fileutils'

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__)).each { |lib| require lib }

RSpec.configure do |config|
  config.include Support::FixtureHelpers

  MatterhornWhymper.configure do |mh_config|
    mh_yml = YAML::load_file( "./spec/matterhorn.yml" )
    mh_config.system_account_user     = mh_yml['matterhorn']['system_account_user']
    mh_config.system_account_password = mh_yml['matterhorn']['system_account_password']
    mh_config.system_domain           = mh_yml['matterhorn']['system_domain']
    mh_config.system_protocol         = mh_yml['matterhorn']['system_protocol']
  end

  logfile_path = File.expand_path('../../log/test.log', __FILE__)
  FileUtils.mkdir_p(File.dirname(logfile_path))
  MatterhornWhymper.logger = Logger.new(File.open(logfile_path, 'a'))
end

module Kernel
  private

  def endpoint_configured?
    MatterhornWhymper.configuration.system_domain.to_s.strip != ''
  end
end