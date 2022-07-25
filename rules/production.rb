require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../store'

module Emissary

    # all hexs produce food and goods which are then transported
    # to the nearest settlement with the distance effecting a cost
    # represented by a reduction of quantity that arrives
    class Production < Rule

        attr_accessor :area

        def initialize(player)
            super(player, TS_PRODUCTION, true)
        end

        def Execute(gameState)

            if @area and @area.closest_settlement

                distance = @area.closest_settlement.distance

                food = @area.food.to_f * @area.population.to_f
                goods = @area.goods.to_f * @area.population.to_f

                # maybe adjust based on state of hex e.g. rebellion / occupied


                # maybe split into another rule but for now just sell to closest
                distance.times { | i |
                    food = food * PRODUCTION_FOOD_TRAVEL_LOSS
                    goods = goods * PRODUCTION_GOODS_TRAVEL_LOSS
                }

                food = food.floor.to_i
                goods = goods.floor.to_i

                @settlement = gameState.getHex(@area.closest_settlement.x, @area.closest_settlement.y)
                if @settlement

                    @settlement.store = Store.new if !@settlement.store
                    @settlement.store.food = @settlement.store.food + food
                    @settlement.store.goods = @settlement.store.goods + goods
                end

            end
        end

    end

end