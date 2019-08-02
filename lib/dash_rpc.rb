require 'dash_rpc/client'
require 'dash_rpc/config'

module DashRPC
  def self.config
    @@config ||= DashRPC::Config.instance
  end
  def self.new(user, password, args={})
     Client.new(user, password, args)
   end
end

DashRPC.config.network = Rails.env.production? ? :livenet : :testnet
DashRPC.config.debug = !Rails.env.production?
