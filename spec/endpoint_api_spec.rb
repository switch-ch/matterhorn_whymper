require 'spec_helper'

describe Matterhorn::EndpointApi do

  it "#info" do
    expect(Matterhorn::EndpointApi.info).to include Matterhorn::EndpointApi::VERSION
  end

end