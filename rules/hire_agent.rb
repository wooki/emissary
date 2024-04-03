require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'
require_relative '../models/agent'

module Emissary
  class HireAgent < Rule
    attr_accessor :coord, :data

    def initialize(player)
      super(player, TS_SET_ORDER)      
    end

    # executes this rule against the gamestate
    def execute(game)
      
      hex = game.getCoord(@coord)
      if !hex
        game.order_error(@player, "Hire agent failed because the province could not be found.");
        return
      end

      cost = hex.hire_cost(game)

      # get the players capital
      kingdom = game.kingdom_by_player(@player)
      capital = game.getCapital(@player)
      if capital.nil? or capital.store.nil?
        game.order_error(@player, "Hire agent failed because the players capital could not be found.");
        return 
      end

      if capital.store.pay(cost) 

        agent = Agent.new game.random_id
        agent.message("Ready for orders.", "Agent")
        agent.owner = @player
        agent.next_payment = game.turn + 12
        agent.will_pay = true
        hex.add_agent agent

        game.info "HIRE", hex, "Agent hired by #{kingdom.name} for 12 turns.", {gold: 0 - cost}
        if hex != capital
          game.info "HIRE", capital, "Agent hired in #{hex.province_name} for 12 turns.", {gold: 0 - cost}
        end
      else
        game.info "HIRE", hex, "#{kingdom.name} failed to hire an agent.", nil
      end
            
    end
  end
end