module ProxyFetcher
  ##
  # ProxyFetcher gem version.
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  ##
  # ProxyFetcher gem semantic versioning.
  module VERSION
    # Major version number
    MAJOR = 0
    # Minor version number
    MINOR = 6
    # Smallest version number
    TINY  = 2

    # Full version number
    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
