require 'thor'

module EnvChecker
  class CLI < Thor
    desc 'version', 'EnvChecker version.'
    def version
      puts "EnvChecker #{EnvChecker::VERSION}"
    end

    option :environment, :aliases => :e, :type => :string
    option :config_file, :aliases => :cf, :type => :string
    option :required_variables, :aliases => [:r, :required], :type => :array
    option :optional_variables, :aliases => [:o, :optional], :type => :array
    option :slack_webhook_url, :aliases => :slack, :type => :string
    option :run, :type => :string
    desc 'check', 'Check optional and required environment variables.'
    def check
      output = []
      output << 'Variables: '

      variables = %w(config_file
                     slack_webhook_url
                     environment
                     run
                     optional_variables
                     required_variables)

      my_options = {}
      variables.each do |v|
        env_var_name = "env_checker_#{v}".upcase
        if ENV[env_var_name]
          my_options[v.to_sym] ||= if env_var_name.include?('_VARIABLES')
                                     ENV[env_var_name].split(' ')
                                   else
                                     ENV[env_var_name]
                                   end
        end
        my_options[v.to_sym] = options[v.to_sym] if options[v.to_sym]
        output << "- #{v}: #{my_options[v.to_sym]}" if my_options[v.to_sym]
      end
      puts output.join("\n")

      EnvChecker.cli_configure_and_check(my_options)
    end
  end
end
