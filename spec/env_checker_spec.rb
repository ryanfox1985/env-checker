require 'spec_helper'

describe EnvChecker do
  it 'check empty variables' do
    expect(EnvChecker.configure {}).to be true
  end

  it 'not valid configuration required_variables as String' do
    expect do
      EnvChecker.configure do |config|
        config.required_variables = 'Potato'
      end
    end.to raise_error(EnvChecker::ConfigurationError)
  end

  it 'not valid configuration optional_variables as String' do
    expect do
      EnvChecker.configure do |config|
        config.optional_variables = 'Potato'
      end
    end.to raise_error(EnvChecker::ConfigurationError)
  end

  it 'not valid configuration slack_webhook_url as array' do
    expect do
      EnvChecker.configure do |config|
        config.slack_webhook_url = %(Potato)
      end
    end.to raise_error(EnvChecker::ConfigurationError)
  end

  it 'valid configuration slack_webhook_url' do
    expect(
      EnvChecker.configure do |config|
        config.slack_webhook_url = 'http://hooks.slack.com/services/xxxx/xxxx/xxxx'
      end
    ).to be(true)

    expect(
      EnvChecker.configure do |config|
        config.slack_webhook_url = 'https://hooks.slack.com/services/xxxx/xxxx/xxxx'
      end
    ).to be(true)
  end

  it 'not valid configuration slack_webhook_url badformated URL' do
    expect do
      EnvChecker.configure do |config|
        config.slack_webhook_url = 'potato_no_url'
      end
    end.to raise_error(EnvChecker::ConfigurationError)
  end

  ENV_VARIABLES = [
    %w(),
    %w(MyVar1 OptMyVar1),
    %w(MyVar1 OptMyVar1 MyVar2 OptMyVar2)
  ].freeze

  ENV_VARIABLES.each do |variables|
    context "#{variables} variables defined" do
      before(:all) do
        variables.each { |var| ENV[var.upcase] = "value_from_#{var}" }
      end

      after(:all) do
        variables.each { |var| ENV.delete(var.upcase) }
      end

      it 'check 2 optional variables' do
        if ENV.key?('MYVAR1') && ENV.key?('MYVAR2')
          expect(EnvChecker.configure do |config|
            config.required_variables = []
            config.optional_variables = %w(MyVar1 MyVar2)
          end).to be true
        else
          expect(EnvChecker.configure do |config|
            config.required_variables = []
            config.optional_variables = %w(MyVar1 MyVar2)
          end).to be false
          # TODO: check call logger and contains the 2 variables
        end
      end

      it 'check 2 required variables' do
        if ENV.key?('MYVAR1') && ENV.key?('MYVAR2')
          expect(EnvChecker.configure do |config|
            config.optional_variables = []
            config.required_variables = %w(MyVar1 MyVar2)
          end).to be true
        else
          expect do
            EnvChecker.configure do |config|
              config.optional_variables = []
              config.required_variables = %w(MyVar1 MyVar2)
            end
          end.to raise_error(EnvChecker::MissingKeysError)
          # TODO: check call logger and contains the 2 variables
        end
      end

      it 'cli check 2 required variables' do
        options = {
          optional_variables: [],
          required_variables: %w(MyVar1 MyVar2)
        }

        if ENV.key?('MYVAR1') && ENV.key?('MYVAR2')
          expect(EnvChecker.cli_configure_and_check(options))
            .to be true
        else
          expect do
            EnvChecker.cli_configure_and_check(options)
          end.to raise_error(EnvChecker::MissingKeysError)
          # TODO: check call logger and contains the 2 variables
        end
      end

      it 'check 2 optional and required variables' do
        if ENV.key?('MYVAR1') && ENV.key?('MYVAR2')
          expect(EnvChecker.configure do |config|
            config.optional_variables = %w(OptMyVar1 OptMyVar2)
            config.required_variables = %w(MyVar1 MyVar2)
          end).to be true
        else
          expect do
            EnvChecker.configure do |config|
              config.optional_variables = %w(OptMyVar1 OptMyVar2)
              config.required_variables = %w(MyVar1 MyVar2)
            end
          end.to raise_error(EnvChecker::MissingKeysError)
          # TODO: check call logger and contains the 2 variables
        end
      end
    end
  end
end
