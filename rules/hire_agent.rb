require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'

module Emissary
  class HireAgent < Rule
    attr_accessor :coord

    def initialize(player)
      super(player, TS_SET_HIRE)
    end

    # executes this rule against the gamestate
    def execute(game)

      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Hire agent failed because the province could not be found.");
        return
      end

      owned = (hex.owner == @player)        

      # cost is based on wealth
      wealth = 1.0
      wealth = wealth + (1.0 * hex.wealth) unless hex.wealth.nil?
      cost = wealth * 12.0 # buy for 12 turns

      # get the players capital
      kingdom = game.kingdom_by_player(@player)
      capital = game.getCapital(@player)
      if capital.nil? or capital.store.nil?
        game.order_error(@player, "Hire agent failed because the players capital could not be found.");
        reutrn 
      end

      if capital.store.pay(cost) 

        agent = Agent.new game.random_id
        agent.message("Ready for orders.", "Agent")
        hex.add_agent agent

        game.info "HIRE", hex, "Agent hired by #{kingdom.name} for 12 turns.", {cost: cost}
      else
        game.info "HIRE", hex, "#{kingdom.name} failed to hire an agent.", nil
      end
            
    end
  end
end