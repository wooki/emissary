require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../models/constants'
require_relative '../rules/trade'

module Emissary

    # all settlements attempt to import food to feed population
    # and goods to feed industry (same number). Dependent on
    # settlement trade policy
    class Import < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_IMPORT, true)
            self.urban = urban
        end

        # registers the buys and returns buy orders to be evaluated
        # after the price is set
        def execute(gameState)

            trades = Array.new

            if @urban and @urban.trade

                # how many food and goods do we need to import
                food_required = @urban.upkeep_food
                goods_required = @urban.industry

                # this is modified by the trade policy
                food_required = (food_required.to_f * @urban.trade_policy_modifier(:food)).ceil.to_i
                goods_required = (goods_required.to_f * @urban.trade_policy_modifier(:goods)).ceil.to_i

                # distance = @urban.trade.distance

                @trade = gameState.getHex(@urban.trade.x, @urban.trade.y)
                if @trade and @trade.trade_node

                    # always buy up to required (but this is import only rule)
                    if @urban.store.food < food_required
                        buy_food = food_required - @urban.store.food
                        max_buy_food = @urban.upkeep_food * 2
                        buy_food = max_buy_food if max_buy_food < buy_food                        

                        # register that we will buy and create order to do so for any cost
                        @trade.trade_node.buy_later(:food, buy_food)
                        trades.push Trade.new(@urban, @trade.trade_node, :food, false, @urban.import_message(:food), buy_food, nil, true)

                        # we will payonly in the trade but deliver immeditely
                        @urban.store.food = @urban.store.food + buy_food
                    end

                    if @urban.store.goods < goods_required
                        buy_goods = goods_required - @urban.store.goods
                        max_buy_goods = @urban.industry * 2
                        buy_goods = max_buy_goods if max_buy_goods < buy_goods

                        @trade.trade_node.buy_later(:goods, buy_goods)
                        trades.push Trade.new(@urban, @trade.trade_node, :goods, false, @urban.import_message(:goods), buy_goods, nil, true)

                        # we will payonly in the trade but deliver immeditely
                        @urban.store.goods = @urban.store.goods + buy_goods
                    end

                end

            end

            trades
        end

    end

end