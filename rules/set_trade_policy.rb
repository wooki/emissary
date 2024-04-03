require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'

module Emissary
  class SetTradePolicy < Rule
    attr_accessor :coord, :data

    def initialize(player)
      super(player, TS_SET_ORDER)
    end

    # executes this rule against the gamestate
    def execute(game)

      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Trade policy not set because the province could not be found.");
        return
      end

      if hex.owner != player 
        game.order_error(@player, "Trade policy not set because you did not own the province.");
        return
      end

      changes = Array.new
      if hex.trade_policy[:food] != @data["food"]
        hex.trade_policy[:food] = @data["food"]
        changes.push "#{@data['food']} food"
      end
      if hex.trade_policy[:goods] != @data["goods"]
        hex.trade_policy[:goods] = @data["goods"]
        changes.push "#{@data['goods']} goods"
      end
      
      if changes.length > 0
        msg = "Trade policy was set to #{changes.join(' and ')}."
      end

      game.info "TRADE", hex, msg, nil          
            
    end
  end
end