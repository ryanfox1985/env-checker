$LOAD_PATH.unshift(File.dirname(__FILE__))

require "env_checker/version"
require "env_checker/missing_keys_error"
require "env_checker/configuration"

module EnvChecker
  class << self
    attr_accessor :configuration

    def check_environment_variables
      if configuration.optional_variables
        missing_keys = missing_keys_environment(configuration.optional_variables)
        puts missing_keys # TODO: do something more.
      end

      if configuration.required_variables
        missing_keys = missing_keys_environment(configuration.required_variables)
        raise MissingKeysError.new(missing_keys) if missing_keys.any?
      end
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    private

    def missing_keys_environment(keys)
      keys.flatten - ::ENV.keys
    end
  end
end
