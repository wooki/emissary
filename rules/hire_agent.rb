require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'

module Emissary
  class HireAgent < Rule
    attr_accessor :coord, :bid

    def initialize(player)
      super(player, TS_SET_TRADE_POLICY)
    end

    # executes this rule against the gamestate
    def execute(game)

      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Hire agent failed because the province could not be found.");
        return
      end

      owned = (hex.owner == player)        

      # quality of agent is based on population in hex

      # ff
      
      
      
      if changes.length > 0
        msg = "Trade policy was set to #{changes.join(' and ')}."
      end

      game.info "TRADE", hex, msg, nil          
            
    end
  end
end