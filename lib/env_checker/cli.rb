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
    option :slack_webhook_url, :aliases => :slack, :type => :string
    desc 'check', 'Check optional and required environment variables.'
    def check
      output = []
      output << 'Variables: '

      variables = %w(config_file slack_webhook_url optional required)
      variables.each do |v|
        # TODO: get config variables from current environment
        # options[v.to_sym] ||= ENV[v.to_sym] if ENV[v.to_sym]
        output << "- #{v}: #{options[v.to_sym]}" if options[v.to_sym]
      end
      puts output.join("\n")

      EnvChecker.cli_configure_and_check(options)
    end
  end
end
