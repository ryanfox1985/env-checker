require 'spec_helper'

describe EnvChecker do
  it 'check empty variables' do
    EnvChecker.configure {}

    expect(EnvChecker.check_environment_variables).to be true
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
      before(:all) { variables.each { |var| ENV[var] = var } }
      after(:all) { variables.each { |var| ENV.delete(var) } }

      it 'check 2 optional variables' do
        EnvChecker.configure do |config|
          config.required_variables = []
          config.optional_variables = %w(MyVar1 MyVar2)
        end

        if ENV.key?('MyVar1') && ENV.key?('MyVar2')
          expect(EnvChecker.check_environment_variables).to be true
        else
          expect(EnvChecker.check_environment_variables).to be false
          # TODO: check call logger and contains the 2 variables
        end
      end

      def check_variables_or_exception
        if ENV.key?('MyVar1') && ENV.key?('MyVar2')
          expect(EnvChecker.check_environment_variables).to be true
        else
          expect { EnvChecker.check_environment_variables }
            .to raise_error(EnvChecker::MissingKeysError)
          # TODO: check call logger and contains the 2 variables
        end
      end

      it 'check 2 required variables' do
        EnvChecker.configure do |config|
          config.optional_variables = []
          config.required_variables = %w(MyVar1 MyVar2)
        end

        check_variables_or_exception
      end

      it 'check 2 optional and required variables' do
        EnvChecker.configure do |config|
          config.optional_variables = %w(OptMyVar1 OptMyVar2)
          config.required_variables = %w(MyVar1 MyVar2)
        end

        check_variables_or_exception
      end
    end
  end
end
