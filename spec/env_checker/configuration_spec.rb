require 'spec_helper'

describe EnvChecker::Configuration do
  it 'create a new configuration' do
    config = EnvChecker::Configuration.new

    expect(config).not_to be nil
    expect(config.required_variables.empty?).to be true
    expect(config.logger).not_to be nil
  end
end
