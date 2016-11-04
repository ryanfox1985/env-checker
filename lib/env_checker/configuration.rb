module EnvChecker
  class Configuration
    # Has default settings, which can be overridden in the initializer.

    attr_accessor :required_variables, :optional_variables, :logger

    def initialize
      @required_variables = []
      @logger = Logger.new(STDERR)
    end
  end
end
