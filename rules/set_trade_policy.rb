require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'

module Emissary
  class SetTradePolicy < Rule
    attr_accessor :coord, :data

    def initialize(player)
      super(player, TS_SET_TRADE_POLICY)
    end

    # executes this rule against the gamestate
    def execute(game)

      puts "EXECUITE TRADE POLICY"
      puts "data: #{@coord} #{@data}"

      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Trade policy not set because the province could not be found.");
        return
      end

      if hex.owner != player 
        game.order_error(@player, "Trade policy not set because you did not own the province.");
        return
      end

      hex.trade_policy[:food] = @data["food"]
      hex.trade_policy[:goods] = @data["goods"]

      msg = "Trade policy was set to #{@data['food']} food and #{@data['goods']} goods."

      game.info "TRADE", hex, msg, nil
      
      
            
    end
  end
end