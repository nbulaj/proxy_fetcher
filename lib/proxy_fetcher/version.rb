module ProxyFetcher
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    # Major version number
    MAJOR = 0
    # Minor version number
    MINOR = 1
    # Smallest version number
    TINY  = 4

    # Full version number
    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
