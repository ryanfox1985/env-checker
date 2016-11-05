# Env-checker

[![Gem Version](https://badge.fury.io/rb/env-checker.svg)](https://badge.fury.io/rb/env-checker)
[![Dependency Status](https://gemnasium.com/badges/github.com/ryanfox1985/env-checker.svg)](https://gemnasium.com/github.com/ryanfox1985/env-checker)
[![Build Status](https://travis-ci.org/ryanfox1985/env-checker.svg?branch=master)](https://travis-ci.org/ryanfox1985/env-checker)
[![Coverage Status](https://coveralls.io/repos/github/ryanfox1985/env-checker/badge.svg?branch=master)](https://coveralls.io/github/ryanfox1985/env-checker?branch=master)
[![Code Climate](https://codeclimate.com/github/ryanfox1985/env-checker/badges/gpa.svg)](https://codeclimate.com/github/ryanfox1985/env-checker)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/ryanfox1985/env-checker/blob/master/LICENSE)


Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/env_checker`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'env-checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install env-checker


## Usage


### Rails or Ruby standalone

Create a initializer to configure the gem and run the hook to check the
environment variables. Example:

```ruby
# config/initializers/env_checker.rb

require 'env_checker'

EnvChecker.configure do |config|
  config.optional_variables = %w(MyVar1 MyVar2)
  config.required_variables = %w(MyVar1 MyVar2)

  # LOGGER
  # ======
  # Default is:
  #
  # config.logger = Logger.new(STDERR)
  #
  # Some possible settings:
  # config.logger = Rails.logger                        # Log with all your app's other messages
  # config.logger = Logger.new('log/env_checker.log')   # Use this file
  # config.logger = Logger.new('/dev/null')             # Don't log at all (on a Unix system)
end

# Example to run always
[YOUR_APP]::Application.config.after_initialize do
  EnvChecker.check_environment_variables
end

# Example to run in specific environments
if Rails.env.production? || Rails.env.test?
  [YOUR_APP]::Application.config.after_initialize do
    EnvChecker.check_environment_variables
  end
end
```


### Standalone and CLI

TODO: Write usage instructions here


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanfox1985/env-checker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
