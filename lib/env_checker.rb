$LOAD_PATH.unshift(File.dirname(__FILE__))

require "env_checker/version"
require "env_checker/missing_keys_error"
require "env_checker/configuration"

module EnvChecker
  class << self
    attr_accessor :configuration

    def check_environment_variables
      check_optional_variables &&
        check_required_variables
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    private

    def check_optional_variables
      if configuration.optional_variables
        missing_keys = missing_keys_env(configuration.optional_variables)
        log_message(:warning, "EnvChecker: Warning missing this optional
          variables: [#{missing_keys}]")

        return missing_keys.empty?
      end

      true
    end

    def check_required_variables
      if configuration.required_variables
        missing_keys = missing_keys_env(configuration.required_variables)

        if missing_keys.any?
          log_message(:error, "EnvChecker: Error missing this required
            variables: [#{missing_keys}]")

          raise MissingKeysError.new(missing_keys)
        end
      end

      true
    end

    def log_message(type, message)
      return unless configuration || configuration.logger

      case type
      when :warning
        configuration.logger.warn(message)
      when :error
        configuration.logger.error(message)
      else
        configuration.logger.info(message)
      end
    end

    def missing_keys_env(keys)
      keys.flatten - ::ENV.keys
    end
  end
end
