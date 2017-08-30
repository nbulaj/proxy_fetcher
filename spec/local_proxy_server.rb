require 'logger'
require 'evil-proxy'

EvilProxy::MITMProxyServer.new(Port: 3128, Logger: Logger.new('/dev/null')).start
