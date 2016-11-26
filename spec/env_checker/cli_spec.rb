require 'spec_helper'

describe EnvChecker::CLI do
  it 'should return version' do
    args = %w(version)
    options = described_class.start(args)
    expect(options).to be EnvChecker::VERSION
  end

  it 'not variables, should raise exception' do
    args = %w(check --required_variables MyVar1 MyVar2)

    expect do
      described_class.start(args)
    end.to raise_error(SystemExit)
  end

  it 'test yaml file config' do
    yml_content = {
      'optional_variables' => %w(OptMyVar1 OptMyVar2),
      'required_variables' => %w(MyVar1 MyVar2)
    }

    File.open 'test_config.yml', 'w' do |f|
      f.write YAML.dump(yml_content)
    end

    args = %w(check --config_file test_config.yml)

    expect do
      described_class.start(args)
    end.to raise_error(SystemExit)
  end

  it 'test yaml file config with two environments' do
    yml_content = {
      'optional_variables' => [],
      'required_variables' => [],
      'environments' => %w(staging),
      'staging' => {
        'optional_variables' => %w(Staging_OptMyVar1 Staging_OptMyVar2),
        'required_variables' => %w(Staging_MyVar1 Staging_MyVar2)
      }
    }

    File.open 'test_config.yml', 'w' do |f|
      f.write YAML.dump(yml_content)
    end

    args = %w(check --config_file test_config.yml -e staging)

    expect do
      described_class.start(args)
    end.to raise_error(SystemExit)
  end

  it 'test sample_config.yml raise error' do
    args = %w(check --config_file sample_config.yml -e staging)

    expect do
      described_class.start(args)
    end.to raise_error(SystemExit)

    expect(EnvChecker.configuration.configurations.size).to eq 3
  end
end
