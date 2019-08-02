require 'singleton'
module DashRPC
  class Config
    include Singleton
    attr_accessor :network, :debug
  end
end
