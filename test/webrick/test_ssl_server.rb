require "test/unit"
require "webrick"
require "webrick/ssl"
require_relative "utils"

class TestWEBrickSSLServer < Test::Unit::TestCase
  class Echo < WEBrick::GenericServer
    def run(sock)
      while line = sock.gets
        sock << line
      end
    end
  end

  def test_self_signed_cert_server
    config = {
      :SSLEnable => true,
      :SSLCertName => [["C", "JP"], ["O", "www.ruby-lang.org"], ["CN", "Ruby"]]
    }
    TestWEBrick.start_server(Echo, config){|server, addr, port, log|
      sock = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(addr, port))
      sock.connect
      sock.puts(server.ssl_context.cert.subject.to_s)
      assert_equal("/C=JP/O=www.ruby-lang.org/CN=Ruby\n", sock.gets, log.call)
      sock.close
    }
  end
end