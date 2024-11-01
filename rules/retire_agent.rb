require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'
require_relative '../models/agent'

module Emissary
  class RetireAgent < Rule
    attr_accessor :coord, :agent, :data

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

      agent = hex.agents[@agent]
      if !hex
        game.order_error(@player, "Retire agent agent failed because the agent could not be found.");
        return
      end

      if agent.owner != @player
        game.order_error(@player, "Retire agent agent failed because the agent was not in your employ.");
        return
      end

      game.retire(@agent)      
      game.info "HIRE", area, "#{kingdom.name} has retired an agent.", nil

    end
  end
end