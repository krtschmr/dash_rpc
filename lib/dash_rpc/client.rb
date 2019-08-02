require 'net/http'
require 'uri'
require 'json'

module DashRPC
  class Client
    class Unauthenticated < StandardError;end;

    attr_accessor :user, :password, :host, :port, :network, :debug

    def initialize(user, password, args={})
      self.network = args.fetch(:network, DashRPC.config.network)
      raise ::ArgumentError.new("unknown network :#{network}") unless [:livenet, :testnet].map(&:to_s).include?(network.to_s)

      self.user = user
      self.password = password
      self.host = args.fetch(:host, "localhost")
      self.port = args.fetch(:port, "19332")
      self.debug = args.fetch(:debug, DashRPC.config.debug || false)
    end

    def validateaddress(address)
      request(:validateaddress, address)
    end

    def importaddress(address, label, rescan=false)
      request(:importaddress, address, label, rescan)
    end

    def rescanblockchain(start_height=250000)
      request(:rescanblockchain, start_height)
    end

    def getconnectioncount
      request(:getconnectioncount)
    end


    def listtransactions(include_sending = false)
      txs = request(:listtransactions, "*", 100, 0, true)
      if include_sending
        txs
      else
        txs.select{|tx|
          tx['category'] == "receive"
        }
      end
    end

    def gettransaction(txid)
      request(:gettransaction, txid, true)
    end


    private

    def base_uri
      "http://#{host}:#{port}/"
    end

    def request(method, *args)
      uri = URI.parse(base_uri)
      header = {'Content-Type': 'text/json'}
      params = {
        jsonrpc: 1.0,
        method: method,
        params: [args].flatten.compact
      }

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.basic_auth(user, password)
      request.body = params.to_json
      if debug
        p "sending request to #{uri}, method: #{method}, args: #{args}" unless Rails.env.test?
      end

      response = http.request(request)

      if response.code == "403"
        raise Unauthenticated
      end

      json = JSON.parse(response.body)
      if json["error"]
        raise "#{json["error"]["code"]} | message: #{json["error"]["message"]}"
      end
      json["result"]
    end

  end
end
