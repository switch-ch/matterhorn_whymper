require 'bundler/setup'
require 'yaml'

Bundler.setup

require 'matterhorn_whymper'
require 'webmock/rspec'

require 'fileutils'

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__)).each { |lib| require lib }


MatterhornWhymper.configure do |mhw_config|
  mhw_yml = YAML::load_file(File.expand_path('../matterhorn.yml', __FILE__))['test']
  mhw_yml.each do |mh_name, mh_config|
    if mh_name != 'default'
      mhw_config.add_matterhorn_instance(mh_name)
      if !mh_config['endpoint'].nil?
        mhw_config.add_endpoint(mh_config['endpoint'], mh_name)
      end
      if !mh_config['api'].nil?
        mhw_config.add_api(mh_config['api'], mh_name)
      end
    else
      mhw_config.set_default_matterhorn_instance(mh_config)
    end
  end
end

logfile_path = File.expand_path('../../log/test.log', __FILE__)
FileUtils.mkdir_p(File.dirname(logfile_path))
MatterhornWhymper.logger = Logger.new(File.open(logfile_path, 'a'))

RSpec.configure do |config|
  config.include Support::FixtureHelpers
end

module Kernel
  private

  def endpoint_configured?
    !!MatterhornWhymper.configuration.endpoint
  end
end