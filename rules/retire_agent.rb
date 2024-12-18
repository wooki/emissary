require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'
require_relative '../models/agent'

module Emissary
  class RetireAgent < Rule
    attr_accessor :coord, :agentid, :retire

    def initialize(player)
      super(player, TS_SET_ORDER)      
    end

    # executes this rule against the gamestate
    def execute(game)
      
      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Retire agent agent failed because the province could not be found.");
        return
      end

      agent = hex.agents[@agentid]
      if !hex
        game.order_error(@player, "Retire agent agent failed because the agent could not be found.");
        return
      end

      if agent.owner != @player
        game.order_error(@player, "Retire agent agent failed because the agent was not in your employ.");
        return
      end

      # get the players capital
      kingdom = game.kingdom_by_player(@player)
            
      if @retire
        game.retire(agent)    
        game.info "HIRE", hex, "#{kingdom.name} has retired an agent.", nil
      end

    end
  end
end