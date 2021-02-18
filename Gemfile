# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "nokogiri", "~> 1.8"
gem "oga", "~> 3.2"
gem "rubocop", "~> 1.0"

group :test do
  gem "coveralls", require: false
  # Until I find a way to introduce other MITM proxy
  gem "webrick", "1.7.0"
  gem "evil-proxy", "~> 0.2"
end
