require 'simplecov'
SimpleCov.add_filter 'spec'
SimpleCov.add_filter 'version'

if ENV['CI'] || ENV['TRAVIS'] || ENV['COVERALLS'] || ENV['JENKINS_URL']
  require 'coveralls'
  Coveralls.wear!
else
  SimpleCov.start
end

require 'bundler/setup'
Bundler.setup

require 'proxy_fetcher'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

adapter = ENV['BUNDLE_GEMFILE'][/.+\/(.+)\.gemfile/i, 1] || :nokogiri
puts "Configured adapter: '#{adapter}'"

ProxyFetcher.configure do |config|
  config.adapter = adapter
end

RSpec.configure do |config|
  config.order = 'random'
end
