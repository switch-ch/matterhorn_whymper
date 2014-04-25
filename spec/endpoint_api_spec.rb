require 'spec_helper'

describe Matterhorn::EndpointApi do

  it "version must be defined" do
    expect(Matterhorn::EndpointApi::VERSION).not_to be nil
  end

  it "#info" do
    expect(Matterhorn::EndpointApi.info).to include Matterhorn::EndpointApi::VERSION
  end

end