# load mattehonr whymper in irb
#
# require "#{File.dirname( __FILE__)}/config/initializers/matterhorn_whymper"
#

require 'yaml'
require 'matterhorn_whymper'


MatterhornWhymper.configure do |mhw_config|
  mhw_yml = YAML.load(File.read(File.expand_path('../../matterhorn.yml', __FILE__)))
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
