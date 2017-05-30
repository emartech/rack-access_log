require "spec_helper"

RSpec.describe Rack::AccessLog do
  it "has a version number" do
    expect(Rack::AccessLog::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
