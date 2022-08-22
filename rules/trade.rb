require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../store'

module Emissary

    # actually buy/sell at the current price - this happens after
    # the orders to buy/sell/import have run and the price has been
    # calculated based on total quantities at nodes
    class Trade < Rule

        attr_accessor :urban, :trade, :commodity, :sell, :number, :spend, :narrative, :payonly

        def initialize(urbal, trade, commodity, sell=false, narrative=nil, number=nil, spend=nil, payonly=false)
            super(nil, TS_TRADE, true)
            self.urban = urban
            self.trade = trade
            self.commodity = commodity
            self.sell = sell
            self.narrative = narrative
            self.number = number
            self.spend = spend

            # allow for goods to be paid for ahead of
            # knowing the price and paying with this
            self.payonly = payonly
        end

        def Execute(gameState)
            # puts "TRADE #{(@sell ? 'SELL' : 'BUY')} #{@number} #{@commodity}"
            if @urban and @trade and @trade.is_node

# @urban.store.bought_food(buy_food, food_cost)

                #         gameState.info "TRADE", @urban, "Food imported to feed population", {food: buy_food, cost: food_cost}


            end
        end

    end

end