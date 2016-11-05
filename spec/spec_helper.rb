$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "env_checker"
require 'coveralls'
require 'simplecov'

SimpleCov.start
Coveralls.wear!
