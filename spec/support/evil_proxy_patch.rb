require 'evil-proxy'

EvilProxy::HTTPProxyServer.class_eval do
  def do_PUT(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.put(path, req.body || '', header)
    end
  end

  def do_DELETE(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.delete(path, header)
    end
  end

  def do_PATCH(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.patch(path, req.body || '', header)
    end
  end

# This method is not needed for PUT but I added for completeness
  def do_OPTIONS(_req, res)
    res['allow'] = 'GET,HEAD,POST,OPTIONS,CONNECT,PUT,PATCH,DELETE'
  end
end
