require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative './behaviour/unrest'

module Emissary

    # all rural hexs reduce their unrest every turn
    class UnrestRecoveryRural < Rule

        attr_accessor :area

        def initialize(area)
            super(nil, TS_RURAL, true)
            self.area = area
        end

        def execute(gameState)

            if @area
                Unrest.ruralDecrease(@area, gameState)                
            end

            nil
        end

    end

end