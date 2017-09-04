# Proxy Fetcher Changelog

Reverse Chronological Order:

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