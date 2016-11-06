require 'logger'

module EnvChecker
  class Configuration
    attr_accessor :required_variables, :optional_variables, :logger, :environment

    # Has default settings, which can be overridden in the initializer.
    def initialize
      @environment = ENV['RACK_ENV'] || ENV['RAILS_ENV']
      @required_variables = []
      @optional_variables = []
      @logger = Logger.new(STDERR)
    end
  end
end
