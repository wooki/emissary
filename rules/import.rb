require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../rules/trade'

module Emissary

    # all settlements attempt to import food to feed population
    # and goods to feed industry (same number). Prices come from
    # last turns exports to trade node.
    # TODO: Amount bought depends on settlement orders, until then just buy optimum
    class Import < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_IMPORT, true)
            self.urban = urban
        end

        # registers the buys and returns buy orders to be evaluated
        # after the price is set
        def Execute(gameState)

            trades = Array.new

            if @urban and @urban.trade

                # how many food and goods do we need to import
                food_required = (@urban.population.to_f * FOOD_CONSUMPTION).floor.to_i
                goods_required = (@urban.population.to_f * INDUSTRY_RATE).floor.to_i
                distance = @urban.trade.distance

                @trade = gameState.getHex(@urban.trade.x, @urban.trade.y)
                if @trade and @trade.trade_node

                    # always buy up to required (but this is import only rule)
                    if @urban.store.food < food_required
                        buy_food = food_required - @urban.store.food

                        # register that we will buy and create order to do so for any cost
                        @trade.trade_node.buy_later(:food, buy_food)
                        trades.push Trade.new(@urban, @trade.trade_node, :food, false, buy_food, nil, "Food imported to feed population")
                    end

                    if @urban.store.goods < goods_required
                        buy_goods = goods_required - @urban.store.goods

                        @trade.trade_node.buy_later(:goods, buy_goods)
                        trades.push Trade.new(@urban, @trade.trade_node, :goods, false, buy_goods, nil, "Goods imported to match industrial capacity")
                    end

                end

            end

            trades
        end

    end

end