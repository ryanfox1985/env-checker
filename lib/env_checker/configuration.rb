require 'logger'

module EnvChecker
  class Configuration
    attr_accessor :required_variables, :optional_variables, :logger

    # Has default settings, which can be overridden in the initializer.
    def initialize
      @required_variables = []
      @optional_variables = []
      @logger = Logger.new(STDERR)
    end
  end
end
