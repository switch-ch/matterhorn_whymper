require 'bundler/setup'
require 'yaml'

Bundler.setup

require 'matterhorn_whymper' # and any other gems you need

RSpec.configure do |config|
  MatterhornWhymper.configure do |mh_config|
    mh_yml = YAML::load_file( "./spec/matterhorn.yml" )
    mh_config.system_account_user     = mh_yml['matterhorn']['system_account_user']
    mh_config.system_account_password = mh_yml['matterhorn']['system_account_password']
    mh_config.system_domain           = mh_yml['matterhorn']['system_domain']
    mh_config.system_protocol         = mh_yml['matterhorn']['system_protocol']
  end
end