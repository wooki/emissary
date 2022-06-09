require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'

module Emissary

    # all hexs produce food and goods which are then transported
    # to the nearest settlement with the distance effecting a cost
    # represented by a reduction of quuantity that arrives
    class Production < Rule

        attr_accessor :area

        def initialize(player)
            super(player, TS_PRODUCTION, true)
        end

        def Execute(gameState)

            # PRODUCTION_FOOD_TRAVEL_LOSS
            # PRODUCTION_GOODS_TRAVEL_LOSS

        end

    end

end