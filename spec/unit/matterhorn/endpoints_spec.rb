require 'spec_helper'

describe Matterhorn::Endpoint do
  it "sets up an ingest endpoint" do
    Matterhorn::Endpoint.open(:ingest) do |ingest_endpoint|
      expect(ingest_endpoint).not_to be nil
      expect(ingest_endpoint.class.name).to eq 'Matterhorn::Endpoint::Ingest'
    end
  end

  it "sets up a workflow endpoint" do
    Matterhorn::Endpoint.open(:workflow) do |workflow_endpoint|
      expect(workflow_endpoint).not_to be nil
      expect(workflow_endpoint.class.name).to eq 'Matterhorn::Endpoint::Workflow'
    end
  end
end
