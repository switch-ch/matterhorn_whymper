require 'spec_helper'

describe Matterhorn::Endpoint do

  it "does ingest endpoint available" do
    Matterhorn::Endpoint.open(:ingest) do |ingest_endpoint|
      expect(ingest_endpoint).not_to be nil
      expect(ingest_endpoint.class.name).to eq 'Matterhorn::Endpoint::Ingest'
    end
  end

  it "does workflow endpoint available" do
    Matterhorn::Endpoint.open(:workflow) do |workflow_endpoint|
      expect(workflow_endpoint).not_to be nil
      expect(workflow_endpoint.class.name).to eq 'Matterhorn::Endpoint::Workflow'
    end
  end

end


describe "Ingest Mediapackages" do
  
  it "creates a mediapackage" do
    Matterhorn::Endpoint.open(:ingest) do |ingest_endpoint|
      ingest_endpoint.createMediaPackage()
      mp_local = ingest_endpoint.media_package
      mp_remote = ingest_endpoint.media_package('remote')
      expect(mp_local).not_to be nil
      expect(mp_remote).not_to be nil
    end
  end
  
end