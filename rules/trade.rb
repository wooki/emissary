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

        def initialize(urban, trade, commodity, sell=false, narrative=nil, number=nil, spend=nil, payonly=false)
            super(nil, TS_TRADE, true)
            self.urban = urban
            self.trade = trade
            self.commodity = commodity
            self.sell = sell
            self.narrative = narrative
            self.number = number
            self.spend = spend

            # allow for goods to be acquired for ahead of time (import)
            # knowing the price and paying with this
            self.payonly = payonly
        end

        def Execute(gameState)
            # puts "TRADE"
            # puts "TRADE #{(@sell ? 'SELL' : 'BUY')} #{@number} #{@commodity}"
            if @urban and @trade and @trade.is_node

                # check number/spend allowed
                price = @trade.prices[@commodity]

                if @commodity == :food && @sell
                    @urban.store.trade_food(-1 * number, -1 * price)
                    gameState.info "TRADE", @urban, "Food exported", {food: number, cost: price}
                elsif @commodity == :food
                    @urban.store.trade_food(number, price)
                    gameState.info "TRADE", @urban, "Food imported", {food: number, cost: price}
                elsif @commodity == :goods && @sell
                    @urban.store.trade_goods(-1 * number, -1 * price)
                    gameState.info "TRADE", @urban, "Goods exported", {goods: number, cost: price}
                elsif @commodity == :goods
                    @urban.store.trade_goods(number, price)
                    gameState.info "TRADE", @urban, "Goods imported", {goods: number, cost: price}
                else

                end


            end
        end

    end

end