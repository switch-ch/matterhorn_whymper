require 'spec_helper'
require 'tempfile'

describe Matterhorn::Endpoint::Ingest do
  before do
    @ingest = Matterhorn::Endpoint::create(:ingest)
    stub_request(:head, %r{}).to_return(status: 200, body: '', headers: { 'WWW-Authenticate' => 'Basic realm="Matterhorn"' })
    stub_request(:get, %r{/ingest/createMediaPackage}).to_return(status: 200, body: file_fixture_contents('empty_media_package.xml'))
  end

  after do
    @ingest.close
  end
  

  it "adds a local file to its media package with addTrack" do
    stub_request(:post, %r{/ingest/addTrack}).to_return(status: 200, body: file_fixture_contents('media_package_with_one_track.xml'))
    @ingest.createMediaPackage
    tempfile = Tempfile.new('source')
    tempfile.close
    begin
      response_body = @ingest.addTrack(tempfile.path, 'source/raw')
      expect(response_body).to start_with('<?xml')
    ensure
      tempfile.unlink
    end
  end

  it "adds a source URL to its media package with addTrack" do
    stub_request(:post, %r{/ingest/addTrack}).to_return(status: 200, body: file_fixture_contents('media_package_with_one_track.xml'))
    @ingest.createMediaPackage
    response_body = @ingest.addTrack('http://example.com/path/to/file', 'source/raw')
    expect(response_body).to start_with('<?xml')
  end

  describe "initialization" do
    it "creates an endpoint instance with open" do
      Matterhorn::Endpoint.open(:ingest) do |client|
        expect(client).to be_kind_of(Matterhorn::Endpoint::Ingest)
      end
    end
  end
end