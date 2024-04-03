require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'
require_relative '../models/agent'
require_relative '../rules/behaviour/hiring'

module Emissary
  class PayAgent < Rule
    attr_accessor :agent

    def initialize(agent)    
      super(nil, TS_UPKEEP, true)      
      @agent = agent
    end

    def execute(game)
      
      if game.turn == @agent.next_payment

        if @agent.will_pay

          # get the players capital
          if @agent.owner
            kingdom = game.kingdom_by_player(@agent.owner)
            capital = game.getCapital(@agent.owner)
            if capital.nil? or capital.store.nil?
              game.order_error(@agent.owner, "Hire agent failed because the players capital could not be found.");
              return 
            end

            game.find_agent(@agent.id) do | agent, area |
            
              cost = Hiring.agent_hire_cost(@agent.level, area, game)

              if capital.store.pay(cost) 

                agent.next_payment = game.turn + 12            

                @agent.message("Has been paid for a further 12 turns.", "Agent")
                game.info "HIRE", area, "Agent re-hired by #{kingdom.name} for 12 turns.", {gold: 0 - cost}
              else
                game.info "HIRE", area, "#{kingdom.name} let an agent retire.", nil
              end
            end
          end      
        else
          game.retire(@agent)
        end

      end          
            
    end
  end
end