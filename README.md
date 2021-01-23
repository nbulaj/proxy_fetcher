# Ruby / JRuby lib for managing proxies
[![Gem Version](https://badge.fury.io/rb/proxy_fetcher.svg)](http://badge.fury.io/rb/proxy_fetcher)
[![Build Status](https://travis-ci.org/nbulaj/proxy_fetcher.svg?branch=master)](https://travis-ci.org/nbulaj/proxy_fetcher)
[![Coverage Status](https://coveralls.io/repos/github/nbulaj/proxy_fetcher/badge.svg)](https://coveralls.io/github/nbulaj/proxy_fetcher)
[![Code Climate](https://codeclimate.com/github/nbulaj/proxy_fetcher/badges/gpa.svg)](https://codeclimate.com/github/nbulaj/proxy_fetcher)
[![Inline docs](http://inch-ci.org/github/nbulaj/proxy_fetcher.png?branch=master)](http://inch-ci.org/github/nbulaj/proxy_fetcher)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem can help your Ruby / JRuby application to make HTTP(S) requests using
proxy by fetching and validating actual proxy lists from multiple providers.

It gives you a special `Manager` class that can load proxy lists, validate them and return random or specific proxies.
It also has a `Client` class that encapsulates all the logic for sending HTTP requests using proxies, automatically
fetched and validated by the gem. Take a look at the documentation below to find all the gem features.

Also this gem can be used with any other programming language (Go / Python / etc) as standalone solution for downloading and
validating proxy lists from the different providers. [Checkout examples](#standalone) of usage below.

## Documentation valid for `master` branch

Please check the documentation for the version of doorkeeper you are using in:
https://github.com/nbulaj/proxy_fetcher/releases

## Table of Contents

- [Dependencies](#dependencies)
- [Installation](#installation)
- [Example of usage](#example-of-usage)
  - [In Ruby application](#in-ruby-application)
  - [Standalone](#standalone)
- [Client](#client)
- [Configuration](#configuration)
  - [Proxy validation speed](#proxy-validation-speed)
- [Proxy object](#proxy-object)
- [Providers](#providers)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

ProxyFetcher gem itself requires Ruby `>= 2.0.0` (or [JRuby](http://jruby.org/) `> 9.0`, but maybe earlier too,
[see Travis build matrix](.travis.yml)) and great [HTTP.rb gem](https://github.com/httprb/http).

However, it requires an adapter to parse HTML. If you do not specify any specific adapter, then it will use
default one - [Nokogiri](https://github.com/sparklemotion/nokogiri). It's OK for any Ruby on Rails project
(because they use it by default).

But if you want to use some specific adapter (for example your application uses [Oga](https://gitlab.com/yorickpeterse/oga),
then you need to manually add your dependencies to your project and configure ProxyFetcher to use another adapter. Moreover,
you can implement your own adapter if it your use-case. Take a look at the [Configuration](#configuration) section for more details.

## Installation

If using bundler, first add 'proxy_fetcher' to your Gemfile:

```ruby
gem 'proxy_fetcher', '~> 0.14'
```

or if you want to use the latest version (from `master` branch), then:

```ruby
gem 'proxy_fetcher', git: 'https://github.com/nbulaj/proxy_fetcher.git'
```

And run:

```sh
bundle install
```

Otherwise simply install the gem:

```sh
gem install proxy_fetcher -v '0.14'
```

## Example of usage

### In Ruby application

By default ProxyFetcher uses all the available proxy providers. To get current proxy list without validation you
need to initialize an instance of `ProxyFetcher::Manager` class. By default ProxyFetcher will automatically load
and parse all the proxies from all available sources:

```ruby
manager = ProxyFetcher::Manager.new # will immediately load proxy list from the servers
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA",
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

You can initialize proxy manager without immediate load of the proxy list from the remote server by passing
`refresh: false` on initialization:

```ruby
manager = ProxyFetcher::Manager.new(refresh: false) # just initialize class instance
manager.proxies

 #=> []
```

Also you could use ProxyFetcher to load proxy lists from local files if you have such:

```ruby
manager = ProxyFetcher::Manager.new(file: "/home/dev/proxies.txt", refresh: false)

# or

manager = ProxyFetcher::Manager.from_file(file: "/home/dev/proxies.txt", refresh: false)

# or

manager = ProxyFetcher::Manager.new(
  files: Dir.glob("/home/dev/proxies/**/*.txt"),
  refresh: false
)
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA",
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

`ProxyFetcher::Manager` class is very helpful when you need to manipulate and manager proxies. To get the proxy
from the list you can call `.get` or `.pop` method that will return first proxy and move it to the end of the list.
This methods has some equivalents like `get!` or aliased `pop!` that will return first **connectable** proxy and
move it to the end of the list. They both marked as danger methods because all dead proxies will be removed from the list.

If you need just some random proxy then call `manager.random_proxy` or it's alias `manager.random`.

To clean current proxy list from the dead entries that does not respond to the requests you you need to use `cleanup!`
or `validate!` method:

```ruby
manager.cleanup! # or manager.validate!
```

This action will enumerate proxy list and remove all the entries that doesn't respond by timeout or returns errors.

In order to increase the performance proxy list validation is performed using Ruby threads. By default gem creates a
pool with 10 threads, but you can increase this number by changing `pool_size` configuration option: `ProxyFetcher.config.pool_size = 50`.
Read more in [Proxy validation speed](#proxy-validation-speed) section.

If you need raw proxy URLs (like `host:port`) then you can use `raw_proxies` methods that will return array of strings:

```ruby
manager = ProxyFetcher::Manager.new
manager.raw_proxies

 # => ["97.77.104.22:3128", "94.23.205.32:3128", "209.79.65.140:8080",
 #     "91.217.42.2:8080", "97.77.104.22:80", "165.234.102.177:8080", ...]
```

You don't need to initialize a new manager every time you want to load actual proxy list from the providers. All you
need is to refresh the proxy list by calling `#refresh_list!` (or `#fetch!`) method for your `ProxyFetcher::Manager` instance:

```ruby
manager.refresh_list! # or manager.fetch!

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA",
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

If you need to filter proxy list, for example, by country or response time and **selected provider supports filtering**
with GET params, then you can just pass your filters like a simple Ruby hash to the Manager instance:

```ruby
ProxyFetcher.config.providers = :xroxy

manager = ProxyFetcher::Manager.new(filters: { country: 'PL', maxtime: '500' })
manager.proxies

 # => [...]
```

**[IMPORTANT]**: All the providers have their own filtering params! So you can't just use something like `country` to
filter all the proxies by country. If you are using multiple providers, then you can split your filters by proxy
provider names:

```ruby
ProxyFetcher.config.providers = [:proxy_docker, :xroxy]

manager = ProxyFetcher::Manager.new(filters: {
  hide_my_name: {
    country: 'PL',
    maxtime: '500'
  },
  xroxy: {
    type: 'All_http'
  }
})

manager.proxies

 # => [...]
```

You can apply different filters every time you calling `#refresh_list!` (or `#fetch!`) method:

```ruby
manager.refresh_list!(country: 'PL', maxtime: '500')

 # => [...]
```

*NOTE*: not all the providers support filtering. Take a look at the provider classes to see if it supports custom filters.

### Standalone

All you need to use this gem is Ruby >= 2.0 (2.4 is recommended). You can install it in a different ways. If you are using Ubuntu Xenial (16.04LTS)
then you already have Ruby 2.3 installed. In other cases you can install it with [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv).

After installing Ruby just bundle the gem by running `gem install proxy_fetcher` in your terminal and now you can run it:

```bash
proxy_fetcher >> proxies.txt # Will download proxies from the default provider, validate them and write to file
```

If you need a list of proxies from some specific provider, then you need to pass it's name with `-p` option:

```bash
proxy_fetcher -p xroxy >> proxies.txt # Will download proxies from the default provider, validate them and write to file
```

If you need a list of proxies in JSON format just pass a `--json` option to the command:

```bash
proxy_fetcher --json

# Will print:
# {"proxies":["120.26.206.178:80","119.61.13.242:1080","117.40.213.26:80","92.62.72.242:1080","77.53.105.155:3124"
# "58.20.41.172:35923","204.116.192.151:35923","190.5.96.58:1080","170.250.109.97:35923","121.41.82.99:1080"]}
```

To get all the possible options run:

```bash
proxy_fetcher --help
```

## Client

ProxyFetcher gem provides you a ready-to-use HTTP client that made requesting with proxies easy. It does all the work 
with the proxy lists for you (load, validate, refresh, find proxy by type, follow redirects, etc). All you need it to
make HTTP(S) requests:

```ruby
require 'proxy_fetcher'

ProxyFetcher::Client.get 'https://example.com/resource'

ProxyFetcher::Client.post 'https://example.com/resource', { param: 'value' }

ProxyFetcher::Client.post 'https://example.com/resource', 'Any data'

ProxyFetcher::Client.post 'https://example.com/resource', { param: 'value'}.to_json , headers: { 'Content-Type': 'application/json' }

ProxyFetcher::Client.put 'https://example.com/resource', { param: 'value' }

ProxyFetcher::Client.patch 'https://example.com/resource', { param: 'value' }

ProxyFetcher::Client.delete 'https://example.com/resource'
```

By default, `ProxyFetcher::Client` makes 1000 attempts to send a HTTP request in case if proxy is out of order or the
remote server returns an error. You can increase or decrease this number for your case or set it to `nil` if you want to
make infinite number of requests (or before your Ruby process will die :skull:):

```ruby
require 'proxy_fetcher'

ProxyFetcher::Client.get 'https://example.com/resource', options: { max_retries: 10_000 }
```

You can also use your own proxy object when using ProxyFetcher client:

```ruby
require 'proxy_fetcher'

manager = ProxyFetcher::Manager.new # will immediately load proxy list from the server

#random will return random proxy object from the list
ProxyFetcher::Client.get 'https://example.com/resource', options: { proxy: manager.random }
```

Btw, if you need support of JavaScript or some other features, you need to implement your own client using, for example,
`selenium-webdriver`.

## Configuration

ProxyFetcher is very flexible gem. You can configure the most important parts of the library and use your own solutions.

Default configuration looks as follows:

```ruby
ProxyFetcher.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.user_agent = ProxyFetcher::Configuration::DEFAULT_USER_AGENT
  config.pool_size = 10
  config.client_timeout = 3
  config.provider_proxies_load_timeout = 30
  config.proxy_validation_timeout = 3
  config.http_client = ProxyFetcher::HTTPClient
  config.proxy_validator = ProxyFetcher::ProxyValidator
  config.providers = ProxyFetcher::Configuration.registered_providers
  config.adapter = ProxyFetcher::Configuration::DEFAULT_ADAPTER # :nokogiri by default
end
```

You can change any of the options above.

For example, you can set your custom User-Agent string:

```ruby
ProxyFetcher.configure do |config|
  config.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36'
end
```

ProxyFetcher uses HTTP.rb gem for dealing with HTTP(S) requests. It is fast enough and has a great chainable API.
If you wanna add, for example, your custom provider that was developed as a Single Page Application (SPA) with some JavaScript,
then you will need something like [selenium-webdriver](https://github.com/SeleniumHQ/selenium/tree/master/rb) to properly
load the content of the website. For those and other cases you can write your own class for fetching HTML content by
the URL and setup it in the ProxyFetcher config:

```ruby
class MyHTTPClient
  # [IMPORTANT]: below methods are required!
  def self.fetch(url)
    # ... some magic to return proper HTML ...
  end
end

ProxyFetcher.config.http_client = MyHTTPClient

manager = ProxyFetcher::Manager.new
manager.proxies

#=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA",
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

You can take a look at the [lib/proxy_fetcher/utils/http_client.rb](lib/proxy_fetcher/utils/http_client.rb) for an example.

Moreover, you can write your own proxy validator to check if proxy is valid or not:

```ruby
class MyProxyValidator
  # [IMPORTANT]: below methods are required!
  def self.connectable?(proxy_addr, proxy_port)
    # ... some magic to check if proxy is valid ...
  end
end

ProxyFetcher.config.proxy_validator = MyProxyValidator

manager = ProxyFetcher::Manager.new
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA",
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]

manager.validate!

 #=> [ ... ]
```

Be default, ProxyFetcher gem uses [Nokogiri](https://github.com/sparklemotion/nokogiri) for parsing HTML. If you want
to use [Oga](https://gitlab.com/yorickpeterse/oga) instead, then you need to add `gem 'oga'` to your Gemfile and configure
ProxyFetcher as follows:

```ruby
ProxyFetcher.config.adapter = :oga
```

Also you can write your own HTML parser implementation and use it, take a look at the [abstract class and implementations](lib/proxy_fetcher/document).
Configure it as:

```ruby
ProxyFetcher.config.adapter = MyHTMLParserClass
```

### Proxy validation speed

There are some tricks to increase proxy list validation performance.

In a few words, ProxyFetcher gem uses threads to validate proxies for availability. Every proxy is checked in a
separate thread. By default, ProxyFetcher uses a pool with a maximum of 10 threads. You can increase this number by
setting max number of threads in the config:

```ruby
ProxyFetcher.config.pool_size = 50
```

You can experiment with the threads pool size to find an optimal number of maximum threads count for you PC and OS.
This will definitely give you some performance improvements.

Moreover, the common proxy validation speed depends on `ProxyFetcher.config.proxy_validation_timeout` option that is equal
to `3` by default. It means that gem will wait 3 seconds for the server answer to check if particular proxy is connectable.
You can decrease this option to `1`, for example, and it will heavily increase proxy validation speed (**but remember**
that some proxies could be connectable, but slow, so with this option you will clear proxy list from the proxies that
works, but very slow).

## Proxy object

Every proxy is a `ProxyFetcher::Proxy` object that has next readers (instance variables):

* `addr` (IP address)
* `port`
* `type` (proxy type, can be HTTP, HTTPS, SOCKS4 or/and SOCKS5)
* `country` (USA or Brazil for example)
* `response_time` (5217 for example)
* `anonymity` (`Low`, `Elite proxy` or `High +KA` for example)

Also you can call next instance methods for every Proxy object:

* `connectable?` (whether proxy server is available)
* `http?` (whether proxy server has a HTTP protocol)
* `https?` (whether proxy server has a HTTPS protocol)
* `socks4?`
* `socks5?`
* `uri` (returns `URI::Generic` object)
* `url` (returns a formatted URL like "_IP:PORT_" or "_http://IP:PORT_" if `scheme: true` provided)

## Providers

Currently ProxyFetcher can deal with next proxy providers (services):

* Free Proxy List
* Free SSL Proxies
* Free Socks Proxies
* Gather Proxy
* HTTP Tunnel Genius
* Proxy List
* XRoxy
* Proxypedia
* MTPro.xyz

If you wanna use one of them just setup it in the config:

```ruby
ProxyFetcher.config.provider = :free_proxy_list

manager = ProxyFetcher::Manager.new
manager.proxies
 #=> ...
```

You can use multiple providers at the same time:

```ruby
ProxyFetcher.config.providers = :free_proxy_list, :xroxy, :proxy_docker

manager = ProxyFetcher::Manager.new
manager.proxies
 #=> ...
```

If you want to use all the possible proxy providers then you can configure ProxyFetcher as follows:

```ruby
ProxyFetcher.config.providers = ProxyFetcher::Configuration.registered_providers

manager = ProxyFetcher::Manager.new
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA", 
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

Moreover, you can write your own provider! All you need is to create a class, that would be inherited from the
`ProxyFetcher::Providers::Base` class, and register your provider like this:

```ruby
ProxyFetcher::Configuration.register_provider(:your_provider, YourProviderClass)
```

Provider class must implement `self.load_proxy_list` and `#to_proxy(html_element)` methods that will load and parse
provider HTML page with proxy list. Take a look at the existing providers in the [lib/proxy_fetcher/providers](lib/proxy_fetcher/providers) directory.

## Contributing

You are very welcome to help improve ProxyFetcher if you have suggestions for features that other people can use.

To contribute:

1. Fork the project.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run <tt>rake doc:yard</tt>. If your changes are not 100% documented, go back to step 4.
6. Add tests for your feature or bug fix.
7. Run `rake spec` to make sure all tests pass.
8. Commit your changes (`git commit -am 'Add new feature'`).
9. Push to the branch (`git push origin my-new-feature`).
10. Create new pull request.

Thanks.

## License

`proxy_fetcher` gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).

Copyright (c) 2017—2018 Nikita Bulai (bulajnikita@gmail.com).
