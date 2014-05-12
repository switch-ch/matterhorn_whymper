require 'bundler/setup'
Bundler.setup

require 'matterhorn_whymper' # and any other gems you need

RSpec.configure do |config|
  MatterhornWhymper.configure do |mh_config|
    mh_config.uri = "http://mh_system_user:4Hlk5jd3@mh-admin.localdomain"
  end
end