require 'spec_helper'

if endpoint_configured?

  describe Matterhorn::Endpoint::Ingest, "when talking to the remote server" do
    include Support::RemoteHelpers

    it "creates a mediapackage" do
      Matterhorn::Endpoint.open(:ingest, nil, :p1) do |ingest_endpoint|
        ingest_endpoint.createMediaPackage()
        mp_local = ingest_endpoint.media_package
        mp_remote = ingest_endpoint.media_package('remote')
        expect(mp_local).not_to be nil
        expect(mp_remote).not_to be nil
      end
    end
  end

end