$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'env_checker/version'
require 'env_checker/missing_keys_error'
require 'env_checker/configuration'
require 'env_checker/cli'
require 'env_checker/notifier'

module EnvChecker
  class << self
    attr_accessor :configurations

    def configure
      self.configurations ||= {}
      configurations['global'] = Configuration.new
      yield(configurations['global'])
      after_configure_and_check(configurations)
    end

    def cli_configure_and_check(options)
      run_configure_and_check(options) && options[:run] &&
        exit(system(options[:run]))

      exit(true)
    end

    private

    def run_configure_and_check(options)
      return true if !options[:optional_variables] &&
                     !options[:required_variables] &&
                     !options[:config_file]

      self.configurations = create_config_from_parameters(options)

      begin
        unless after_configure_and_check(configurations)
          exit(options[:run] ? system(options[:run]) : 1)
        end
      rescue EnvChecker::MissingKeysError
        exit 2
      rescue EnvChecker::ConfigurationError
        exit 3
      end

      true
    end

    def after_configure_and_check(configurations)
      environments_to_check = %w(global)

      current_env = configurations['global'].environment
      if current_env && configurations.key?(current_env)
        environments_to_check << current_env
      end

      environments_to_check.map do |env|
        configurations[env].after_initialize

        check_optional_variables(env, configurations) &
          check_required_variables(env, configurations)
      end.reduce(:&)
    end

    def create_config_from_parameters(options)
      configurations = { 'global' => Configuration.new }
      attributes = %w(environments
                      environment
                      optional_variables
                      required_variables
                      slack_webhook_url)

      if options[:config_file]
        from_file = YAML.load_file(options[:config_file])

        configurations = config_from_file('global', attributes, from_file)
        if configurations['global'].environments.any?
          configurations['global'].environments.each do |env|
            configurations
              .merge!(config_from_file(env, attributes, from_file[env]))
          end
        end
      end

      attributes.each do |a|
        options[a.to_sym] &&
          configurations['global'].public_send("#{a}=", options[a.to_sym])
      end

      configurations
    end

    def config_from_file(name, attributes, from_file)
      return { name => Configuration.new } unless from_file

      config = Configuration.new
      attributes.each do |a|
        config.public_send("#{a}=", from_file[a]) if from_file[a]
      end

      { name => config }
    end

    def check_optional_variables(env, configurations)
      return true if
        !configurations[env].optional_variables ||
        configurations[env].optional_variables.empty?

      missing_keys = missing_keys_env(configurations[env].optional_variables)
      return true if missing_keys.empty?

      Notifier.log_message(
        configurations[env],
        :warning,
        env,
        "Warning! Missing optional variables: #{missing_keys}"
      )

      false
    end

    def check_required_variables(env, configurations)
      return true if
        !configurations[env].required_variables ||
        configurations[env].required_variables.empty?

      missing_keys = missing_keys_env(configurations[env].required_variables)

      if missing_keys.any?
        Notifier.log_message(
          configurations[env],
          :error,
          env,
          "Error! Missing required variables: #{missing_keys}"
        )

        raise MissingKeysError.new(missing_keys)
      end

      true
    end

    def missing_keys_env(keys)
      keys.flatten - ::ENV.keys
    end
  end
end
