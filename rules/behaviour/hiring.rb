require_relative '../../models/constants'

# calc for hire cost of agents
module Emissary

    class Hiring

        def self.agent_hire_cost(level, area, game)
            
            return nil if @population == 0
            cost = 0

            # cost is based on wealth of province    
            if area.kind_of? Settlement
                cost = 1.0 + (1.0 * area.wealth)                
            else
                cost_factor = 1.0 - (AGENT_COST_PER_DISTANCE * area.province.distance)
                urban = game.getHex(area.province.x, area.province.y)    
                cost = [0.25, cost_factor].max + (1.0 * urban.wealth)                
            end

            cost = cost * AGENT_COST_PER_MONTH * 12.0 # buy for 12 turns
            cost = cost * AGENT_COST_PER_LEVEL * Math.sqrt(level)

            cost.round.to_i
          end

    end
        

end
