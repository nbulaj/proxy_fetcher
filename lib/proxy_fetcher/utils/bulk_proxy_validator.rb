# frozen_string_literal: true

module ProxyFetcher
  # This class validates list of proxies.
  # Each proxy is validated using <code>ProxyFetcher::ProxyValidator</code>.
  class BulkProxyValidator
    # @!attribute [r] proxies
    #   @return [Array<ProxyFetcher::Proxy>] Source array of proxies
    attr_reader :proxies
    # @!attribute [r] valid_proxies
    #   @return [Array<ProxyFetcher::Proxy>] Array of valid proxies after validation
    attr_reader :valid_proxies

    # @param [Array<ProxyFetcher::Proxy>] *proxies
    #   Any number of <code>ProxyFetcher::Proxy</code> to validate
    def initialize(*proxies)
      @proxies = proxies.flatten
    end

    # Performs validation
    #
    # @return [Array<ProxyFetcher::Proxy>]
    #   list of valid proxies
    def validate
      target_proxies = @proxies.dup
      target_proxies_lock = Mutex.new
      connectable_proxies = []
      connectable_proxies_lock = Mutex.new
      threads = []

      ProxyFetcher.config.pool_size.times do
        threads << Thread.new do
          loop do
            proxy = target_proxies_lock.synchronize { target_proxies.shift }
            break unless proxy

            connectable_proxies_lock.synchronize { connectable_proxies << proxy } if proxy.connectable?
          end
        end
      end

      threads.each(&:join)

      @valid_proxies = connectable_proxies
    end
  end
end
