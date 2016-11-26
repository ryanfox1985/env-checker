require 'logger'
require 'slack-notifier'
require 'uri'

module EnvChecker
  class ConfigurationError < StandardError; end

  class Configuration
    ATTRIBUTES = %w(required_variables optional_variables environment
                    config_file slack_webhook_url environments).freeze
    OBJECTS = %w(logger slack_notifier configurations).freeze

    attr_accessor *ATTRIBUTES.map(&:to_sym)
    attr_accessor *OBJECTS.map(&:to_sym)

    # Has default settings, which can be overridden in the initializer.
    def initialize
      @environment = ENV['RACK_ENV'] || ENV['RAILS_ENV']
      @environments = []
      @required_variables = []
      @optional_variables = []
      @configurations = {}
      @logger = Logger.new(STDERR)
    end

    def after_initialize
      if @config_file
        from_file = YAML.load_file(@config_file)

        Configuration.options_to_config(self, from_file)
        if environments.any?
          environments.each do |env|
            configurations[env] = Configuration.options_to_config(
              Configuration.new, from_file[env] || {}
            )
          end
        end
      end

      valid?
      configurations.map { |_, config| config.valid? }

      @slack_webhook_url &&
        @slack_webhook_url != '' &&
        @slack_notifier = Slack::Notifier.new(@slack_webhook_url)

      @required_variables &&
        @required_variables = @required_variables.map(&:upcase)

      @optional_variables &&
        @optional_variables = @optional_variables.map(&:upcase)

      true
    end

    def valid?
      if required_variables && required_variables.class != Array
        raise ConfigurationError,
              "Invalid value required_variables: #{required_variables}"
      end

      if optional_variables && optional_variables.class != Array
        raise ConfigurationError,
              "Invalid value optional_variables: #{optional_variables}"
      end

      unless valid_url?(slack_webhook_url)
        raise ConfigurationError,
              "Invalid value slack_webhook_url: #{slack_webhook_url}"
      end

      true
    end

    def self.options_to_config(configuration, options)
      Configuration::ATTRIBUTES.each do |a|
        options[a] &&
          configuration.public_send("#{a}=", options[a])

        options[a.to_sym] &&
          configuration.public_send("#{a}=", options[a.to_sym])
      end

      configuration
    end

    private

    def valid_url?(uri)
      return true unless uri

      valid = (uri =~ URI.regexp(%w(http https)))
      valid && valid.zero?
    end
  end
end
