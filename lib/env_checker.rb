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

      attributes = %w(environment
                      optional_variables
                      required_variables
                      slack_webhook_url)

      if options[:config_file]
        from_file = YAML.load_file(options[:config_file])

        attributes.each do |a|
          config.public_send("#{a}=", from_file[a]) if from_file[a]
        end

        return { 'global' => config }
      end

      attributes.each do |a|
        config.public_send("#{a}=", options[a.to_sym]) if options[a.to_sym]
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

      configuration.notify_slack(message)
      # TODO: add other integrations like email...
      configuration.notify_logger(type, message)
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
