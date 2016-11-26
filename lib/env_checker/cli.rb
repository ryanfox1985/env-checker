require 'thor'

module EnvChecker
  class Parameters
    class << self
      def parse_options(options)
        my_options = {}

        (%w(config_file run) + Configuration::ATTRIBUTES).each do |v|
          env_var_name = "env_checker_#{v}".upcase
          if ENV[env_var_name]
            my_options[v.to_sym] ||= if env_var_name.include?('_VARIABLES')
                                       ENV[env_var_name]
                                         .split(' ')
                                         .map { |elem| elem.split(',') }
                                         .flatten
                                     else
                                       ENV[env_var_name]
                                     end
          end
          my_options[v.to_sym] = options[v.to_sym] if options[v.to_sym]
        end

        my_options
      end
    end
  end

  class CLI < Thor
    desc 'version', 'EnvChecker version.'
    def version
      puts "EnvChecker #{EnvChecker::VERSION}"
      EnvChecker::VERSION
    end

    option :environment, aliases: :e, type: :string
    option :config_file, aliases: :cf, type: :string
    option :required_variables, aliases: [:r, :required], type: :array
    option :optional_variables, aliases: [:o, :optional], type: :array
    option :slack_webhook_url, aliases: :slack, type: :string
    option :verbose, aliases: :v, type: :boolean, default: false
    option :run, type: :string
    desc 'check', 'Check optional and required environment variables.'
    def check
      output = %w(Variables:)

      my_options = Parameters.parse_options(options)
      output += my_options.map { |k, v| "- #{k}: #{v}" }
      puts output.sort.join("\n") if options[:verbose]

      result = 0
      if options[:optional_variables] || options[:required_variables] ||
         options[:config_file]
        begin
          result = 1 unless EnvChecker.cli_configure_and_check(my_options)
        rescue EnvChecker::MissingKeysError
          exit 2
        rescue EnvChecker::ConfigurationError
          exit 3
        end
      end

      exit(options[:run] ? system(options[:run]) : result)
    end
  end
end
