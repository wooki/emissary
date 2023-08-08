require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../store'

module Emissary

    # actually buy/sell at the current price - this happens after
    # the orders to buy/sell/import have run and the price has been
    # calculated based on total quantities at nodes
    class Trade < Rule

        attr_accessor :urban, :trade, :commodity, :sell, :number, :limit, :narrative, :payonly

        def initialize(urban, trade, commodity, sell=false, narrative=nil, number=nil, limit=nil, payonly=false)
            super(nil, TS_TRADE, true)
            self.urban = urban
            self.trade = trade
            self.commodity = commodity
            self.sell = sell
            self.narrative = narrative
            self.number = number
            self.limit = limit

            # allow for goods to be acquired for ahead of time (import)
            # knowing the price and paying with this
            self.payonly = payonly
        end

        def Execute(gameState)

            # puts "TRADE #{(@sell ? 'SELL' : 'BUY')} #{@number} #{@commodity}"
            if @urban and @trade and @trade.is_node

                # what is the price
                price = @trade.price(@commodity, @number)

                # skim off cost of trade
                cost_of_trade = price * @trade.trade_percentage(@urban)
                gross_price = price + cost_of_trade

                # if selling then limit can set a max to pay and will reduce
                # to buy as many as can without going over that limit
                if !@sell and @limit
                    allowed_price_per_item = @limit.to_f / @number.to_f
                    price_per_item = gross_price.to_f / @number.to_f
                    if allowed_price_per_item < price_per_item
                        max_items = (@limit.to_f / allowed_price_per_item.to_f).floor.to_i
                        @number = max_items
                        price = @trade.price(@commodity, @number)
                        cost_of_trade = price * @trade.trade_percentage(@urban)
                        gross_price = price + cost_of_trade
                    end
                end

                qty_multiplier = 1
                qty_multiplier = 0 if payonly

                if @commodity == :food && @sell
                    @urban.store.trade_food(qty_multiplier * -1 * number, -1 * gross_price)
                    gameState.info "TRADE", @urban, "Food exported", {food: number, cost: gross_price}
                elsif @commodity == :food
                    @urban.store.trade_food(qty_multiplier * number, gross_price)
                    gameState.info "TRADE", @urban, "Food imported", {food: number, cost: gross_price}
                elsif @commodity == :goods && @sell
                    @urban.store.trade_goods(qty_multiplier * -1 * number, -1 * gross_price)
                    gameState.info "TRADE", @urban, "Goods exported", {goods: number, cost: gross_price}
                elsif @commodity == :goods
                    @urban.store.trade_goods(qty_multiplier * number, gross_price)
                    gameState.info "TRADE", @urban, "Goods imported", {goods: number, cost: gross_price}
                else

                end


            end
        end

    end

end