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

            if @urban

                # consume food based on population, if not enough then lose
                # loyalty or create unrest

                # wealthy settlements consume more food (also apply this to the import rule)

                if @urban.store.food > @urban.upkeep_food

                    @urban.store.food = @urban.store.food - @urban.upkeep_food

                    gameState.info "UPKEEP", @urban, "Population consumed #{@urban.upkeep_food} food"
                else
                    unrest = @urban.store.food # do something with this

                    gameState.info "UPKEEP", @urban, "There was not enough food for the population. They required #{@urban.upkeep_food} food, unrest is growing"

                    @urban.store.food = 0
                end


            end

        end

    end

end