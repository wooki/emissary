require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../models/constants'
require_relative '../rules/trade'
require_relative './behaviour/wealth'

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
        def execute(gameState)

            trades = Array.new

            if @urban and @urban.trade

                # how many food and goods do we require
                food_required = @urban.upkeep_food
                goods_required = @urban.industry

                # this is modified by the trade policy
                food_required = (food_required.to_f * @urban.import_policy_modifier(:food)).ceil.to_i
                goods_required = (goods_required.to_f * @urban.import_policy_modifier(:goods)).ceil.to_i

                @trade = gameState.getHex(@urban.trade.x, @urban.trade.y)
                if @trade and @trade.trade_node

                    total_exported = 0

                    # do we have excess
                    if @urban.store.food > food_required
                        excess_food = @urban.store.food - food_required
                        total_exported = total_exported + excess_food

                        @trade.trade_node.sell_later(:food, excess_food)
                        trades.push Trade.new(@urban, @trade.trade_node, :food, true, "Food exported", excess_food)
                    end

                    if @urban.store.goods > goods_required
                        excess_goods = @urban.store.goods - goods_required
                        total_exported = total_exported + excess_goods

                        @trade.trade_node.sell_later(:goods, excess_goods)
                        trades.push Trade.new(@urban, @trade.trade_node, :goods, true, "Goods exported", excess_goods)
                    end

                    if total_exported > 0
                        Wealth.exported(@urban, total_exported, gameState)
                    end
                end

            end

            trades
        end

    end

end