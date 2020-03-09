# frozen_string_literal: true

module ProxyFetcher
  # ProxyFetcher Manager class for interacting with proxy lists from various providers.
  class Manager
    REFRESHER_LOCK = Mutex.new

    class << self
      def from_files(files, **options)
        new(**options.merge(files: Array(files)))
      end

      alias from_file from_files
    end

    # @!attribute [r] proxies
    #   @return [Array<ProxyFetcher::Proxy>] An array of proxies
    attr_reader :proxies

    # Initialize ProxyFetcher Manager instance for managing proxies
    #
    # refresh: true - load proxy list from the remote server on initialization
    # refresh: false - just initialize the class, proxy list will be empty ([])
    #
    # @return [Manager]
    #
    def initialize(**options)
      if options.fetch(:refresh, true)
        refresh_list!(options.fetch(:filters, {}))
      else
        @proxies = []
      end

      files = Array(options.fetch(:file, options.fetch(:files, [])))
      load_proxies_from_files!(files) if files&.any?

      cleanup! if options.fetch(:validate, false)
    end

    # Update current proxy list using configured providers.
    #
    # @param filters [Hash] providers filters
    #
    def refresh_list!(filters = nil)
      @proxies = []
      threads = []

      ProxyFetcher.config.providers.each do |provider_name|
        threads << Thread.new do
          provider = ProxyFetcher::Configuration.providers_registry.class_for(provider_name)
          provider_filters = filters && filters.fetch(provider_name.to_sym, filters)
          provider_proxies = provider.fetch_proxies!(provider_filters)

          REFRESHER_LOCK.synchronize do
            @proxies.concat(provider_proxies)
          end
        end
      end

      threads.each(&:join)

      @proxies
    end

    alias fetch! refresh_list!

    # Pop just first proxy (and back it to the end of the proxy list).
    #
    # @return [ProxyFetcher::Proxy, NilClass]
    #   proxy object from the list
    #
    def get
      return if @proxies.empty?

      first_proxy = @proxies.shift
      @proxies << first_proxy

      first_proxy
    end

    alias pop get

    # Pop first valid proxy (and back it to the end of the proxy list)
    # Invalid proxies will be removed from the list
    #
    # @return [ProxyFetcher::Proxy, NilClass]
    #   proxy object from the list
    #
    def get!
      index = proxies.find_index(&:connectable?)
      return if index.nil?

      proxy = proxies.delete_at(index)
      tail = proxies[index..-1]

      @proxies = tail << proxy

      proxy
    end

    alias pop! get!

    # Loads proxies from files.
    #
    # @param proxy_files [String, Array<String,Pathname>]
    #   file path of list of files to load
    #
    def load_proxies_from_files!(proxy_files)
      proxy_files = Array(proxy_files)
      return if proxy_files.empty?

      proxy_files.each do |proxy_file|
        File.foreach(proxy_file, chomp: true) do |proxy_string|
          addr, port = proxy_string.split(":", 2)
          port = Integer(port) if port
          @proxies << Proxy.new(addr: addr, port: port)
        end
      end

      @proxies.uniq!
    end

    # Clean current proxy list from dead proxies (that doesn't respond by timeout)
    #
    # @return [Array<ProxyFetcher::Proxy>]
    #   list of valid proxies
    def cleanup!
      valid_proxies = ProxyListValidator.new(@proxies).validate
      @proxies &= valid_proxies
    end

    alias validate! cleanup!

    # Returns random proxy
    #
    # @return [Proxy]
    #   random proxy from the loaded list
    #
    def random_proxy
      proxies.sample
    end

    alias random random_proxy

    # Returns array of proxy URLs (just schema + host + port)
    #
    # @return [Array<String>]
    #   collection of proxies
    #
    def raw_proxies
      proxies.map(&:url)
    end

    # @private No need to put all the attr_readers to the output
    def inspect
      to_s
    end
  end
end
