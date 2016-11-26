$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'env_checker/version'
require 'env_checker/missing_keys_error'
require 'env_checker/configuration'
require 'env_checker/cli'
require 'env_checker/notifier'

module EnvChecker
  class << self
    attr_accessor :configuration

    def configure
      self.configuration = Configuration.new
      yield(configuration)
      after_configure_and_check
    end

    def cli_configure_and_check(options)
      self.configuration = Configuration.options_to_config(
        Configuration.new, options
      )

      after_configure_and_check
    end

    private

    def after_configure_and_check
      configuration.after_initialize
      environments = { 'global' => configuration }

      current_env = configuration.environment
      if current_env &&
         configuration.configurations.key?(current_env)
        environments[current_env] = configuration.configurations[current_env]
      end

      environments.map do |name, config|
        check_optional_variables(name, config) &
          check_required_variables(name, config)
      end.reduce(:&)
    end

    def check_optional_variables(name, config)
      missing_keys = missing_keys_env(config.optional_variables)
      return true if missing_keys.empty?

      Notifier.log_message(
        config,
        :warning,
        name,
        "Warning! Missing optional variables: #{missing_keys}"
      )

      false
    end

    def check_required_variables(name, config)
      missing_keys = missing_keys_env(config.required_variables)
      return true if missing_keys.empty?

      Notifier.log_message(
        config,
        :error,
        name,
        "Error! Missing required variables: #{missing_keys}"
      )

      raise MissingKeysError, missing_keys
    end

    def missing_keys_env(keys)
      return [] unless keys
      keys.flatten - ::ENV.keys
    end
  end
end
