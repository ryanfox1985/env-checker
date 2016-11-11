require 'spec_helper'

describe EnvChecker::CLI do
  it 'test optional file config' do
    params = { required: %w(MyVar1 MyVar2) }

    expect do
      ::EnvChecker.cli_configure_and_check(params)
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

    params = { config_file: 'test_config.yml' }

    expect do
      EnvChecker.cli_configure_and_check(params)
    end.to raise_error(SystemExit)
  end
end
