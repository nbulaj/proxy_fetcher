if ENV['CI'] || ENV['TRAVIS'] || ENV['COVERALLS'] || ENV['JENKINS_URL']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'bundler/setup'
Bundler.setup

require 'proxifier'

RSpec.configure do |config|
  config.order = 'random'
end
