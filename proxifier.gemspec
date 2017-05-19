$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'proxifier/version'

Gem::Specification.new do |gem|
  gem.name = 'proxifier'
  gem.version = Proxifier.gem_version
  gem.date = '2017-05-19'
  gem.summary = 'Ruby gem for dealing with proxy lists '
  gem.description = 'This gem can help your Ruby application to make HTTP(S) requests ' \
                    'from proxy server, fetching and validating current proxy lists from the HideMyAss service.'
  gem.authors = ['Nikita Bulai']
  gem.email = 'bulajnikita@gmail.com'
  gem.require_paths = ['lib']
  gem.files = `git ls-files`.split($RS)
  gem.homepage = 'http://github.com/nbulaj/proxifier'
  gem.license = 'MIT'
  gem.required_ruby_version = '>= 2.2.2'

  gem.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6'

  gem.add_development_dependency 'rspec', '~> 3.5'
end
