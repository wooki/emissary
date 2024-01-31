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

      # quality of agent is based on population in hex and how much your'e bidding
      # best agent is 9 but that requires a large sum to be spent in a large town
      big_population = 30000
      big_bid = 20
      
      
      # if owned and unrest is high then agent is worse
      # if owned and unrest is low then agent is better
      # if not owned and unrest is high then agent is better
      
      # randomly assign "pips" to their three but rule is 
      # that no stat can ever be more than 2 more than another
      # so once you have 3,1,1 you can't have 4,1,1 you must have 3,2,1

      if changes.length > 0
        msg = "Trade policy was set to #{changes.join(' and ')}."
      end

      game.info "TRADE", hex, msg, nil          
            
    end
  end
end