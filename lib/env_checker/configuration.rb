require 'logger'
require 'slack-notifier'

module EnvChecker
  class ConfigurationError < StandardError; end

  class Configuration
    attr_accessor :required_variables, :optional_variables, :logger,
                  :environment, :slack_webhook_url, :slack_notifier

    # Has default settings, which can be overridden in the initializer.
    def initialize
      @environment = ENV['RACK_ENV'] || ENV['RAILS_ENV']
      @required_variables = []
      @optional_variables = []
      @slack_webhook_url = nil
      @slack_notifier = nil
      @logger = Logger.new(STDERR)
    end

    def valid?
      # TODO: check types and raise invalid config
      true
    end

    def after_initialize
      @slack_webhook_url &&
        @slack_webhook_url != '' &&
        @slack_notifier = Slack::Notifier.new(@slack_webhook_url)

      true
    end
  end
end
