require 'simplecov'
require 'coveralls'
require 'byebug'

SimpleCov.start
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'env_checker'
