# Proxy Fetcher Changelog

Reverse Chronological Order:

## `master`

* Add your description here

## `0.10.2` (2019-03-15)

* Remove ProxyDocker provider (no longer workable)

## `0.10.1` (2019-03-07)

* Fix broken ProxyDocker provider.
* Refactor gem internals.

## `0.9.0` (2019-01-22)

* Fix a problem with stuck of proxies list loading.

* Add a possibility to configure different timeouts for different cases:
  - `client_timeout` - timeout for `ProxyFetcher::Client`.
  - `provider_proxies_load_timeout` - timeout for loading of proxies list by provider.
  - `proxy_validation_timeout` - timeout for proxy validation with `ProxyFetcher::ProxyValidator`. 
  
  (old option `timeout` sets and returns value of `client_timeout`)

## `0.8.0` (2018-11-12)

* Improve speed of proxy list loading.
* Improve speed of proxies cleanup. 
* Fix ProxyDocker provider

## `0.7.2` (2018-08-13)

* Fix XRoxy provider

## `0.7.1` (2018-07-13)

* Fix XRoxy provider

## `0.7.0` (2018-06-04)

* Migrate to `HTTP.rb` instead of `Net::HTTP`
* Fixes

## `0.6.5` (2018-04-20)

* Fix providers

## `0.6.4` (2018-03-26)

* Fix providers

## `0.6.3` (2018-01-26)

* Add ability to use own proxy for `ProxyFetcher::Client`
* Improve specs

## `0.6.2` (2017-12-27)

* Fix ProxyDocker provider.

## `0.6.1` (2017-12-11)

* Fix gem executable to check dependencies for adapters
* Code cleanup
* Some new specs

## `0.6.0` (2017-12-08)

* Make HTML parser configurable (Nokogiri, Oga, custom one)
* Documentation

## `0.5.1` (2017-11-13)

* Fix ProxyFetcher CLI

## `0.5.0` (2017-09-06)

* Remove HideMyName provider (not works anymore)
* Fix ProxyDocker provider
* Add `ProxyFetcher::Client` to make interacting with proxies easier
* Add new providers (Gather Proxy & HTTP Tunnel Genius)
* Simplify `connection_timeout` config option to `timeout`
* Make User-Agent configurable
* Move all the gem exceptions under `ProxyFetcher::Error` base class
* Small improvements

## `0.4.1` (2017-09-04)

* Use all registered providers by default
* Disable HideMyName provider (now ше uses CloudFlare)

## `0.4.0` (2017-08-26)

* Support operations with multiple providers
* Refactor filtering
* Small bugfixes
* Documentation

## `0.3.1` (2017-08-24)

* Remove speed from proxy (no need to)
* Extract proxy validation from the HTTPClient to separate class
* Make proxy validator configurable
* Refactor proxy validation behavior
* Refactor Proxy object (OpenStruct => PORO, url / uri methods, etc)
* Optimize proxy list check with threads
* Improve proxy_fetcher bin

## `0.3.0` (2017-08-21)

* Proxy providers refactoring
* Proxy object refactoring
* Specs refactoring
* New providers
* Custom HTTP client
* Configuration improvements
* Proxy filters

## `0.2.5` (2017-08-17)

* Configurable HTTPClient
* Fix errors handling

## `0.2.3` (2017-08-10)

* Fix broken providers
* Add new providers
* Docs

## `0.2.2` (2017-07-20)

* Code & specs refactoring

## `0.2.1` (2017-07-19)

* New proxy providers
* Bugfixes

## `0.2.0` (2017-07-17)

* New proxy providers
* Custom providers
* Network errors handling
* Specs refactorirng

## `0.1.4` (2017-05-31)

* Code & specs refactoring
* Add `speed` to `Proxy` object
* Docs

## `0.1.3` (2017-05-25)

* Proxy list management with `ProxyFetcher::Manager`

## `0.1.2` (2017-05-23)

* HTTPS proccesing
* `Proxy` object sugar
* Specs improvements
* Docs improvements

## `0.1.1` (2017-05-22)

* Configuration (timeouts)
* Documentation

## `0.1.0` (2017-05-19)

* Initial release