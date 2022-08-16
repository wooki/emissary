require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../store'

module Emissary

    FOOD_PER_POPULATION = 0.001

    # all settlements consume 1 food per 1000 population
    class Upkeep < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_UPKEEP, true)
            self.urban = urban
        end

        def Execute(gameState)

            if @urban and @urban.trade
            end

        end

    end

end