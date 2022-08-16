require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../store'

module Emissary

    POPULATION_PER_INDUSTRY = 0.001

    # all settlements produces 1 good for each good+1000 population they have
    class Industry < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_INDUSTRY, true)
            self.urban = urban
        end

        def Execute(gameState)

            if @urban and @urban.trade
            end

        end

    end

end