DashRPC

    gem "dash_rpc", github: "krtschmr/dash_rpc"

Always develop in testnet!

similar to the BitcoinRPC and the the LitecoinRPC.

Please for and add your functionality to make a robust gem!


    DashRPC.config.network = Rails.env.production? ? :livenet : :testnet
    DashRPC.config.debug = !Rails.env.production?


    client = DashRPC.new( "test", "test", host: "192.168.0.200", port: 1337)
    client.listtransactions.each do |tx|
      tx_id = tx["txid"]
      address = tx["address"]
      amount = tx["amount"]
      confirmations = tx["confirmations"]  
      # do something
    end
