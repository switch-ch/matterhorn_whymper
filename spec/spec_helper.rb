require 'bundler/setup'
require 'yaml'

Bundler.setup

require 'matterhorn_whymper'
require 'webmock/rspec'

require 'fileutils'

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__)).each { |lib| require lib }

test_configuration = YAML::load_file(File.expand_path('../matterhorn.yml', __FILE__))
MatterhornWhymper.configure do |config|
  config.add_matterhorn_instance
  config.add_endpoint(test_configuration['test'])
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