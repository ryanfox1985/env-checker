$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'env_checker/version'
require 'env_checker/missing_keys_error'
require 'env_checker/configuration'
require 'env_checker/cli'

module EnvChecker
  class << self
    attr_accessor :configuration

    def check_environment_variables
      return true unless configuration

      bov = check_optional_variables
      brv = check_required_variables

      bov & brv
    end

    def configure
      self.configuration = Configuration.new
      yield(configuration)
    end

    def cli_configure_and_check(options)
      return if !options[:optional] &&
                !options[:required] &&
                !options[:config_file]

      self.configuration = create_config_from_parameters(options)

      begin
        check_environment_variables ? exit(true) : exit(1)
      rescue EnvChecker::MissingKeysError
        exit 2
      end
    end

    private

    def create_config_from_parameters(options)
      config = Configuration.new

      if options[:config_file]
        from_file = YAML.load_file(options[:config_file])
        config.optional_variables = from_file['optional_variables']
        config.required_variables = from_file['required_variables']

        return config
      end

      config.optional_variables = options[:optional] if options[:optional]
      config.required_variables = options[:required] if options[:required]

      config
    end

    def check_optional_variables
      return true if
        !configuration.optional_variables ||
        configuration.optional_variables.empty?

      missing_keys = missing_keys_env(configuration.optional_variables)
      log_message(:warning,
                  configuration.environment,
                  "Warning! Missing these optional variables: #{missing_keys}")

      missing_keys.empty?
    end

    def check_required_variables
      return true if
        !configuration.required_variables ||
        configuration.required_variables.empty?

      missing_keys = missing_keys_env(configuration.required_variables)

      if missing_keys.any?
        log_message(:error,
                    configuration.environment,
                    "Error! Missing these required variables: #{missing_keys}")

        raise MissingKeysError.new(missing_keys)
      end

      true
    end

    def log_message(type, environment, error_message)
      return unless error_message

      message = format_error_message(environment, error_message)
      # TODO: add other integrations like slack, email...
      return unless configuration.logger

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
