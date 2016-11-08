$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'env_checker/version'
require 'env_checker/missing_keys_error'
require 'env_checker/configuration'

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
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    private

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
