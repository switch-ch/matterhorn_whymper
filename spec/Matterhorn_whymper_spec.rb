require 'spec_helper'

describe MatterhornWhymper do

  it "version must be defined" do
    expect(MatterhornWhymper::VERSION).not_to be nil
  end

  it "#info" do
    expect(MatterhornWhymper.info).to include MatterhornWhymper
    ::VERSION
  end

end