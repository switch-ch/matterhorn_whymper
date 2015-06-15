require 'spec_helper'
require 'tempfile'

describe Matterhorn::Endpoint::Series do
  before do
    @series = Matterhorn::Endpoint::Series.new('enil.ch')
    stub_request(:head, %r{}).to_return(status: 200, body: '', headers: { 'WWW-Authenticate' => 'Basic realm="Matterhorn"' })
  end

  it "reads a Dublin Core document for a series" do
    series_id = SecureRandom.uuid
    stub_request(:get, %r(/enil/series/#{series_id}.xml)).to_return(status: 200, body: file_fixture_contents('series_dublin_core.xml'))

    dublin_core = @series.read(series_id)
    expect(dublin_core.dcterms_title).to eq('Space is Awesome')
  end

  it "returns an error when reading a Dublin Core document for a non-existent series" do
    series_id = SecureRandom.uuid
    stub_request(:get, %r(/enil/series/#{series_id}.xml)).to_return(status: 404, body: '')

    dublin_core = @series.read(series_id)
    expect(dublin_core).to be_nil
  end

  describe "initialization" do
    it "creates an endpoint instance with open" do
      Matterhorn::Endpoint.open(:series) do |client|
        expect(client).to be_kind_of(Matterhorn::Endpoint::Series)
      end
    end
  end
end