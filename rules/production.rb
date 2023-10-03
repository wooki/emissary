require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../models/constants'
require_relative '../models/store'

module Emissary

    # all hexs produce food and goods which are then transported
    # to the nearest settlement with the distance effecting a cost
    # represented by a reduction of quantity that arrives
    class Production < Rule

        attr_accessor :area

        def initialize(area)
            super(nil, TS_PRODUCTION, true)
            self.area = area
        end

        def execute(gameState)

            if @area and @area.province

                distance = @area.province.distance

                food = @area.food.to_f * @area.population.to_f
                goods = @area.goods.to_f * @area.population.to_f

                # adjust based on state of hex e.g. rebellion / occupied


                # maybe split into another rule but for now just send to closest
                distance.times { | i |
                    food = food * PRODUCTION_FOOD_TRAVEL_LOSS
                    goods = goods * PRODUCTION_GOODS_TRAVEL_LOSS
                }

                food = food.floor.to_i
                goods = goods.floor.to_i

                @settlement = gameState.getHex(@area.province.x, @area.province.y)
                if @settlement

                    @settlement.store = Store.new if !@settlement.store
                    @settlement.store.food = @settlement.store.food + food
                    @settlement.store.goods = @settlement.store.goods + goods

                    # log info
                    if food > 0 or goods > 0
                        gameState.info "PRODUCTION", @area, "Food and Goods sent to #{@settlement.name}", {food: food, goods: goods}
                        gameState.info "PRODUCTION", @settlement, "Food and Goods arrived from #{@area.name}", {food: food, goods: goods}
                    end
                end

            end

            nil
        end

    end

end