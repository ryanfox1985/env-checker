require 'logger'
require 'slack-notifier'
require 'uri'

module EnvChecker
  class ConfigurationError < StandardError; end

  class Configuration
    attr_accessor :required_variables, :optional_variables, :logger,
                  :environment, :slack_webhook_url, :slack_notifier,
                  :environments

    # Has default settings, which can be overridden in the initializer.
    def initialize
      @environment = ENV['RACK_ENV'] || ENV['RAILS_ENV']
      @environments = []
      @required_variables = []
      @optional_variables = []
      @slack_webhook_url = nil
      @slack_notifier = nil
      @logger = Logger.new(STDERR)
    end

    def after_initialize
      valid?

      @slack_webhook_url &&
        @slack_webhook_url != '' &&
        @slack_notifier = Slack::Notifier.new(@slack_webhook_url)

      @required_variables &&
        @required_variables = @required_variables.map(&:upcase)

      @optional_variables &&
        @optional_variables = @optional_variables.map(&:upcase)

      true
    end

    private

    def valid?
      if required_variables && required_variables.class != Array
        raise ConfigurationError.new("Invalid value required_variables: #{required_variables}")
      end

      if optional_variables && optional_variables.class != Array
        raise ConfigurationError.new("Invalid value optional_variables: #{optional_variables}")
      end

      unless valid_url?(slack_webhook_url)
        raise ConfigurationError.new("Invalid value slack_webhook_url: #{slack_webhook_url}")
      end

      true
    end

    def valid_url?(uri)
      return true unless uri

      valid = (uri =~ URI.regexp(%w(http https)))
      valid && valid.zero?
    end
  end
end
