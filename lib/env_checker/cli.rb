require 'thor'

module EnvChecker
  class CLI < Thor
    desc 'version', 'EnvChecker version.'
    def version
      puts "EnvChecker #{EnvChecker::VERSION}"
    end

    option :config_file, :aliases => :cf, :type => :string
    option :required, :aliases => :r, :type => :array
    option :optional, :aliases => :o, :type => :array
    desc 'check', 'Check optional and required environment variables.'
    def check
      output = []
      output << 'Variables: '
      output << "- Config file: #{options[:config_file]}" if options[:config_file]
      output << "- Optional: #{options[:optional]}" if options[:optional]
      output << "- Required: #{options[:required]}" if options[:required]
      puts output.join("\n")

      EnvChecker.cli_configure_and_check(options)
    end
  end
end
