require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../rules/trade'

module Emissary

    # all settlements export excess food and goods after upkeep and industry
    class Export < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_EXPORT, true)
            self.urban = urban
        end

        # registers the sells and returns buy orders to be evaluated
        # after the price is set
        def Execute(gameState)

            trades = Array.new

            if @urban and @urban.trade

                # how many food and goods do we require
                food_required = (@urban.population.to_f * FOOD_CONSUMPTION).floor.to_i

                # goods required epends on wealth as some will be kept back
                # and converted to gold/wealth etc.
                # for now set to zero and sell all each turn
                # goods_required = (@urban.population.to_f * INDUSTRY_RATE).floor.to_i
                goods_required = 0

                @trade = gameState.getHex(@urban.trade.x, @urban.trade.y)
                if @trade and @trade.trade_node

                    # do we have excess
                    if @urban.store.food > food_required
                        excess_food = @urban.store.food - food_required

                        @trade.trade_node.sell_later(:food, excess_food)
                        trades.push Trade.new(@urban, @trade.trade_node, :food, true, excess_food, nil, "Food exported")
                    end

                    if @urban.store.goods > goods_required
                        excess_goods = @urban.store.goods - goods_required

                        @trade.trade_node.sell_later(:goods, excess_goods)
                        trades.push Trade.new(@urban, @trade.trade_node, :goods, true, excess_goods, nil, "Goods exported")
                    end

                end

            end

            trades
        end

    end

end