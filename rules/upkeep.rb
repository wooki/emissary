require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../models/constants'
require_relative '../models/store'
require_relative './behaviour/wealth'
require_relative './behaviour/unrest'

module Emissary

    FOOD_PER_POPULATION = 0.001

    # all settlements consume 1 food per 1000 population
    class Upkeep < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_UPKEEP, true)
            self.urban = urban
        end

        def execute(gameState)


            if @urban

                # consume food based on population, if not enough then lose
                # loyalty or create unrest

                # wealthy settlements consume more food (also apply this to the import rule)

                if @urban.store.food >= @urban.upkeep_food

                    Unrest.metUpkeep(@urban, gameState)

                    @urban.store.food = @urban.store.food - @urban.upkeep_food
                    gameState.info "UPKEEP", @urban, "Population consumed #{@urban.upkeep_food} food"
                else
                    unrest = @urban.upkeep_food - @urban.store.food # do something with this

                    Wealth.failedUpkeep(@urban, unrest, gameState)
                    Unrest.failedUpkeep(@urban, unrest, gameState)

                    gameState.info "UPKEEP", @urban, "There was not enough food for the population. They required #{@urban.upkeep_food} food, unrest is growing"
                    @urban.store.food = 0
                end


            end

        end

    end

end