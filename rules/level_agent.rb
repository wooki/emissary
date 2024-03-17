require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'
require_relative '../models/agent'

module Emissary
  class LevelAgent < Rule
    attr_accessor :agent

    def initialize(agent)    
      super(nil, TS_LEVEL_AGENT, true)      
      @agent = agent
    end

    def execute(game)
      
      # aray of possible improvements
      level_up = []
      level_up.push :range if @agent.range < 10 and @agent.range < [@agent.depth + 2, @agent.skill + 2].min
      level_up.push :depth if @agent.depth < 10 and @agent.depth < [@agent.range + 2, @agent.skill + 2].min
      level_up.push :skill if @agent.skill < 10 and @agent.skill < [@agent.depth + 2, @agent.range + 2].min

      if level_up.length > 0
        level_skill = level_up.sample
        if level_skill == :range
          @agent.range += 1
          @agent.message("Has increased the extent of his spy network", "Agent")
        elsif level_skill == :depth
          @agent.depth += 1
          @agent.message("Has made friends in high places", "Agent")
        elsif level_skill == :skill
          @agent.skill += 1
          @agent.message("Has hired some useful operators", "Agent")
        end
      end
            
    end
  end
end