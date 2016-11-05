require "spec_helper"

describe EnvChecker do
  it "has a version number" do
    expect(EnvChecker::VERSION).not_to be nil
  end

  it "create a new configuration" do
    config = EnvChecker::Configuration.new

    expect(config).not_to be nil
    expect(config.required_variables.empty?).to be true
    expect(config.logger).not_to be nil
  end
end
