require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'

module Emissary
  class SetTradePolicy < Rule
    attr_accessor :coord, :food, :goods

    def initialize(player)
      super(player, TS_SET_ORDER)
    end

    # executes this rule against the gamestate
    def execute(game)
      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Trade policy not set because the province could not be found.")
        return
      end

      if hex.owner != player 
        game.order_error(@player, "Trade policy not set because you did not own the province.")
        return
      end

      changes = []
      if hex.trade_policy[:food] != @food
        hex.trade_policy[:food] = @food
        changes.push "#{@food} food"
      end
      
      if hex.trade_policy[:goods] != @goods
        hex.trade_policy[:goods] = @goods
        changes.push "#{@goods} goods"
      end
      
      if changes.length > 0
        msg = "Trade policy was set to #{changes.join(' and ')}."
        game.info "TRADE", hex, msg, nil          
      end
    end
  end
end