# Ruby lib for managing proxies
[![Gem Version](https://badge.fury.io/rb/proxy_fetcher.svg)](http://badge.fury.io/rb/proxy_fetcher)
[![Build Status](https://travis-ci.org/nbulaj/proxy_fetcher.svg?branch=master)](https://travis-ci.org/nbulaj/proxy_fetcher)
[![Coverage Status](https://coveralls.io/repos/github/nbulaj/proxy_fetcher/badge.svg)](https://coveralls.io/github/nbulaj/proxy_fetcher)
[![Code Climate](https://codeclimate.com/github/nbulaj/proxy_fetcher/badges/gpa.svg)](https://codeclimate.com/github/nbulaj/proxy_fetcher)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem can help your Ruby application to make HTTP(S) requests from proxy by fetching and validating actual
proxy lists from the different providers like [HideMyName](https://hidemy.name/en/).

It gives you a `Manager` class that can load proxy list, validate it and return random or specific proxy entry. Take a look
at the documentation below to find all the gem features.

Also this gem can be used as standalone solution for downloading and validating proxy lists from the different providers.
Checkout examples of usage below.

## Installation

If using bundler, first add 'proxy_fetcher' to your Gemfile:

```ruby
gem 'proxy_fetcher', '~> 0.3'
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
gem install proxy_fetcher -v '0.3'
```

## Example of usage

### In Ruby application

Get current proxy list without validation:

```ruby
manager = ProxyFetcher::Manager.new # will immediately load proxy list from the server
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA", 
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

You can initialize proxy manager without immediate load of proxy list from the remote server by passing `refresh: false` on initialization:

```ruby
manager = ProxyFetcher::Manager.new(refresh: false) # just initialize class instance
manager.proxies

 #=> []
```

If you wanna clean current proxy list from some dead servers that does not respond to the requests, than you can just call `cleanup!` method:

```ruby
manager.cleanup! # or manager.validate!
```

Get raw proxy URLs as Strings:

```ruby
manager = ProxyFetcher::Manager.new
manager.raw_proxies

 # => ["97.77.104.22:3128", "94.23.205.32:3128", "209.79.65.140:8080",
 #     "91.217.42.2:8080", "97.77.104.22:80", "165.234.102.177:8080", ...]
```

If `ProxyFetcher::Manager` was already initialized somewhere, you can refresh the proxy list by calling `#refresh_list!` method:

```ruby
manager.refresh_list! # or manager.fetch!

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA", 
 #     @response_time=5217, @type="HTTP", @anonymity="High">, ... ]
```

If you need to filter proxy list, for example, by country or response time and selected provider supports filtering by GET params, then you
can pass your filters to the Manager instance like that:

```ruby
ProxyFetcher.config.provider = :hide_my_name

manager = ProxyFetcher::Manager.new(filters: { country: 'AO', maxtime: '500' })
manager.proxies

 # => [...]
```

*NOTE*: not all the providers support filtering. Take a look at the provider class to see if it supports custom filters.

You can use two methods to get the first proxy from the list:

* `get` or aliased `pop` (will return first proxy and move it to the end of the list)
* `get!` or aliased `pop!` (will return first **connectable** proxy and move it to the end of the list; all the proxies till the working one will be removed)

Or you can get just random proxy by calling `manager.random_proxy` or it's alias `manager.random`.

### Standalone

All you need to use this gem is Ruby >= 2.0 (2.3 is recommended). You can install it in a different ways. If you are using Ubuntu Xenial (16.04LTS)
then you already have Ruby 2.3 installed. In other cases you can install it with [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv).

Just install the gem by running `gem install proxy_fetcher` in your terminal and run it:

```bash
proxy_fetcher >> proxies.txt # Will download proxies from the default provider, validate them and write to file
```

If you need a list of proxies from some specific provider, then you need to pass it's name with `-p` option:

```bash
proxy_fetcher -p proxy_docker >> proxies.txt # Will download proxies from the default provider, validate them and write to file
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
* `url` (returns a formatted URL like "_http://IP:PORT_" )

## Configuration

To change open/read timeout for `cleanup!` and `connectable?` methods you need to change ProxyFetcher.config:

```ruby
ProxyFetcher.configure do |config|
  config.connection_timeout = 1 # default is 3
end

manager = ProxyFetcher::Manager.new
manager.cleanup!
```

ProxyFetcher uses simple Ruby solution for dealing with HTTP(S) requests - `net/http` library from the stdlib. If you wanna add, for example, your custom provider that
was developed as a Single Page Application (SPA) with some JavaScript, then you will need something like [selenium-webdriver](https://github.com/SeleniumHQ/selenium/tree/master/rb)
to properly load the content of the website. For those and other cases you can write your own class for fetching HTML content by the URL and setup it
in the ProxyFetcher config:

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

## Providers

Currently ProxyFetcher can deal with next proxy providers (services):

* Hide My Name (default one)
* Free Proxy List
* Free SSL Proxies
* Proxy Docker
* Proxy List
* XRoxy

If you wanna use one of them just setup required in the config:

```ruby
ProxyFetcher.config.provider = :free_proxy_list

manager = ProxyFetcher::Manager.new
manager.proxies
 #=> ...
```

Also you can write your own provider. All you need is to create a class, that would be inherited from the
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

Copyright (c) 2017 Nikita Bulai (bulajnikita@gmail.com).
