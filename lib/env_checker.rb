$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'env_checker/version'
require 'env_checker/missing_keys_error'
require 'env_checker/configuration'
require 'env_checker/cli'
require 'byebug'

module EnvChecker
  class << self
    attr_accessor :configurations

    def configure
      self.configurations ||= {}
      configurations['global'] = Configuration.new
      yield(configurations['global'])
      after_configure_and_check(configurations['global'])
    end

    def cli_configure_and_check(options)
      if run_configure_and_check(options) && options[:run]
        exit(system(options[:run]))
      end

      exit(true)
    end

    private

    def run_configure_and_check(options)
      return true if !options[:optional_variables] &&
                     !options[:required_variables] &&
                     !options[:config_file]

      self.configurations = create_config_from_parameters(options)

      begin
        exit(1) unless after_configure_and_check(configurations['global'])
      rescue EnvChecker::MissingKeysError
        exit 2
      rescue EnvChecker::ConfigurationError
        exit 3
      end

      true
    end

    def after_configure_and_check(configuration)
      configuration.after_initialize

      bov = check_optional_variables(configuration)
      brv = check_required_variables(configuration)

      bov & brv
    end

    def create_config_from_parameters(options)
      config = Configuration.new

      if options[:config_file]
        from_file = YAML.load_file(options[:config_file])
        config.optional_variables = from_file['optional_variables']
        config.required_variables = from_file['required_variables']
        config.slack_webhook_url = from_file['slack_webhook_url']

        return { 'global' => config }
      end

      config.environment = options[:environment] if options[:environment]
      if options[:optional_variables]
        config.optional_variables = options[:optional_variables]
      end

      if options[:required_variables]
        config.required_variables = options[:required_variables]
      end

      if options[:slack_webhook_url]
        config.slack_webhook_url = options[:slack_webhook_url]
      end

      { 'global' => config }
    end

    def check_optional_variables(configuration)
      return true if
        !configuration.optional_variables ||
        configuration.optional_variables.empty?

      missing_keys = missing_keys_env(configuration.optional_variables)
      return true if missing_keys.empty?

      log_message(configuration,
                  :warning,
                  configuration.environment,
                  "Warning! Missing optional variables: #{missing_keys}")

      false
    end

    def check_required_variables(configuration)
      return true if
        !configuration.required_variables ||
        configuration.required_variables.empty?

      missing_keys = missing_keys_env(configuration.required_variables)

      if missing_keys.any?
        log_message(configuration,
                    :error,
                    configuration.environment,
                    "Error! Missing required variables: #{missing_keys}")

        raise MissingKeysError.new(missing_keys)
      end

      true
    end

    def log_message(configuration, type, environment, error_message)
      return unless error_message

      message = format_error_message(environment, error_message)

      configuration.slack_notifier &&
        configuration.slack_notifier.ping(message)
      # TODO: add other integrations like email...

      configuration.logger &&
        case type
        when :warning
          configuration.logger.warn(message)
        when :error
          configuration.logger.error(message)
        else
          configuration.logger.info(message)
        end
    end

    def format_error_message(environment, error_message)
      return [] unless error_message

      messages = []
      messages << '[EnvChecker]'
      messages << "[#{environment}]" if environment
      messages << error_message
      messages.join(' ')
    end

    def missing_keys_env(keys)
      keys.flatten - ::ENV.keys
    end
  end
end
