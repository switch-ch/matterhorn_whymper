require 'bundler/setup'
Bundler.setup

require 'matterhorn/endpoint_api' # and any other gems you need

RSpec.configure do |config|
  Matterhorn::EndpointApi.configure do |mh_config|
    mh_config.uri = "http://mh_system_user:4Hlk5jd3@mh-admin.localdomain"
  end
end