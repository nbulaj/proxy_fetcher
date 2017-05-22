# Ruby lib for managing proxies
[![Build Status](https://travis-ci.org/nbulaj/proxy_fetcher.svg?branch=master)](https://travis-ci.org/nbulaj/proxy_fetcher)
[![Coverage Status](https://coveralls.io/repos/github/nbulaj/proxy_fetcher/badge.svg)](https://coveralls.io/github/nbulaj/proxy_fetcher)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem can help your Ruby application to make HTTP(S) requests from proxy server, fetching and validating
current proxy lists from the [HideMyAss](http://hidemyass.com/) service.

## Installation

If using bundler, first add 'proxy_fetcher' to your Gemfile:

```ruby
gem 'proxy_fetcher', '~> 0.1'
```

And run:

```sh
bundle install
```

Otherwise simply install the gem:

```sh
gem install proxy_fetcher -v '0.1'
```

## Example of usage

Get current proxy list:

```ruby
manager = ProxyFetcher::Manager.new # will immediately load proxy list from the server
manager.proxies

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port="3128", @country="USA", 
 #     @response_time="5217", @speed="48", @connection_time="100", @type="HTTP", @anonymity="High">, ... ]
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
manager.refresh_list!

 #=> [#<ProxyFetcher::Proxy:0x00000002879680 @addr="97.77.104.22", @port="3128", @country="USA", 
 #     @response_time="5217", @speed="48", @connection_time="100", @type="HTTP", @anonymity="High">, ... ]
```

Every proxy is a `ProxyFetcher::Proxy` object that has next readers:

* `addr` (IP address)
* `port`
* `country` (USA or Brazil for example)
* `response_time` (5217 for example)
* `connection_time` (rank from 0 to 100, where 0 — slow, 100 — high)
* `speed` (rank from 0 to 100, where 0 — slow, 100 — high)
* `type` (URI schema, HTTP for example)
* `anonimity` (Low or High +KA for example)

Also you can call next instance method for every Proxy object:

* `connectable?` (whether proxy server is available)
* `http?` (whether proxy server has a HTTP protocol)
* `https?` (whether proxy server has a HTTPS protocol)
* `uri` (returns `URI::Generic` object)
* `url` (returns a formatted URL like "_http://IP:PORT_" )

If you wanna clear current proxy manager list from dead servers, you can just call `cleanup!` method:

```ruby
manager.cleanup!
```

To change open/read timeout for `cleanup!` and `connectable?` methods yu need to change ProxyFetcher::Manager config:

```ruby
ProxyFetcher::Manager.config.read_timeout = 1 # default is 3
ProxyFetcher::Manager.config.open_timeout = 1# default is 3

manager = ProxyFetcher::Manager.new
manager.cleanup!
```

## Contributing

You are very welcome to help improve ProxyFetcher if you have suggestions for features that other people can use.

To contribute:

1. Fork the project.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run <tt>rake doc:yard</tt>. If your changes are not 100% documented, go back to step 4.
6. Add tests for your feature or bug fix.
7. Run `rake` to make sure all tests pass.
8. Commit your changes (`git commit -am 'Add new feature'`).
9. Push to the branch (`git push origin my-new-feature`).
10. Create new pull request.

Thanks.

## License

proxy_fetcher gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).

Copyright (c) 2017 Nikita Bulai (bulajnikita@gmail.com).
