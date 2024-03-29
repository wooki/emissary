require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../models/constants'
require_relative '../models/store'

module Emissary

    # after buy sells registered set price based on activity
    class TradePrices < Rule

        attr_accessor :trade_node

        def initialize(trade_node)
            super(nil, TS_TRADEPRICES, true)
            self.trade_node = trade_node
        end

        def execute(gameState)

            if @trade_node and @trade_node.is_node

                @trade_node.set_prices                
            end
        end

    end

end