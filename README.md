# Ruby lib for managing proxies
[![Gem Version](https://badge.fury.io/rb/proxy_fetcher.svg)](http://badge.fury.io/rb/proxy_fetcher)
[![Build Status](https://travis-ci.org/nbulaj/proxy_fetcher.svg?branch=master)](https://travis-ci.org/nbulaj/proxy_fetcher)
[![Coverage Status](https://coveralls.io/repos/github/nbulaj/proxy_fetcher/badge.svg)](https://coveralls.io/github/nbulaj/proxy_fetcher)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem can help your Ruby application to make HTTP(S) requests from proxy by fetching and validating actual
proxy lists from the different providers like [HideMyAss](http://hidemyass.com/) or Hide My Name.

It gives you a `Manager` class that can load proxy list, validate it and return random or specific proxy entry. Take a look
at the documentation below to find all the gem features.

**IMPORTANT** currently HideMyAss service closed free proxy list service, but it will be open soon and gem will be updated.

## Installation

If using bundler, first add 'proxy_fetcher' to your Gemfile:

```ruby
gem 'proxy_fetcher', '~> 0.2'
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
gem install proxy_fetcher -v '0.2'
```

## Example of usage

Get current proxy list:

```ruby
manager = ProxyFetcher::Manager.new # will immediately load proxy list from the server
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA", 
 #     @response_time=5217, @speed=48, @type="HTTP", @anonymity="High">, ... ]
```

You can initialize proxy manager without loading proxy list from the remote server by passing `refresh: false` on initialization:

```ruby
manager = ProxyFetcher::Manager.new(refresh: false) # just initialize class instance
manager.proxies

 #=> []
```

Get raw proxy URLs:

```ruby
manager = ProxyFetcher::Manager.new
manager.raw_proxies

 # => ["http://97.77.104.22:3128", "http://94.23.205.32:3128", "http://209.79.65.140:8080",
 #     "http://91.217.42.2:8080", "http://97.77.104.22:80", "http://165.234.102.177:8080", ...]
```

If `ProxyFetcher::Manager` was already initialized somewhere, you can refresh the proxy list by calling `#refresh_list!` method:

```ruby
manager.refresh_list! # or manager.fetch!

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port=3128, @country="USA", 
 #     @response_time=5217, @speed=48, @type="HTTP", @anonymity="High">, ... ]
```

Every proxy is a `ProxyFetcher::Proxy` object that has next readers (instance variables):

* `addr` (IP address)
* `port`
* `country` (USA or Brazil for example)
* `response_time` (5217 for example)
* `speed` (`:slow`, `:medium` or `:fast`. **Note:** depends on the proxy provider and can be `nil`)
* `type` (URI schema, HTTP or HTTPS)
* `anonimity` (Low or High +KA for example)

Also you can call next instance methods for every Proxy object:

* `connectable?` (whether proxy server is available)
* `http?` (whether proxy server has a HTTP protocol)
* `https?` (whether proxy server has a HTTPS protocol)
* `uri` (returns `URI::Generic` object)
* `url` (returns a formatted URL like "_http://IP:PORT_" )

You can use two methods to get the first proxy from the list:

* `get` or aliased `pop` (will return first proxy and move it to the end of the list)
* `get!` or aliased `pop!` (will return first **connectable** proxy and move it to the end of the list; all the proxies till the working one will be removed)

If you wanna clear current proxy manager list from dead servers, you can just call `cleanup!` method:

```ruby
manager.cleanup! # or manager.validate!
```

You can sort or find any proxy by speed using next 3 instance methods:

* `fast?`
* `medium?`
* `slow?`'

To change open/read timeout for `cleanup!` and `connectable?` methods yu need to change ProxyFetcher.config:

```ruby
ProxyFetcher.config.read_timeout = 1 # default is 3
ProxyFetcher.config.open_timeout = 1 # default is 3

manager = ProxyFetcher::Manager.new
manager.cleanup!
```

## Providers

Currently ProxyFetcher can deal with next proxy providers (services):

* Hide My Name (default one)
* Free Proxy List
* HideMyAss

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

Provider class must implement `self.load_proxy_list` and `#parse!(html_entry)` methods that will load and parse
provider HTML page with proxy list. Take a look at the samples in the `proxy_fetcher/providers` directory.

## TODO

* Add proxy filters
* Code refactoring
* Rewrite specs

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

proxy_fetcher gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).

Copyright (c) 2017 Nikita Bulai (bulajnikita@gmail.com).

Some parser code (c) [pifleo](https://gist.github.com/pifleo/3889803)
