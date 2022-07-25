require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'

module Emissary

    # all settlements attempt to import food to feed population
    # and goods to feed industry (same number). Prices come from
    # last turns exports to trade node.
    # TODO: Amount bought depends on settlement orders, until then just buy optimum
    class Import < Rule

        attr_accessor :urban

        def initialize(player)
            super(player, TS_IMPORT, true)
        end

        def Execute(gameState)

            if @urban and @urban.trade

                # how many food and goods do we need to import

                distance = @urban.trade.distance

                @trade = gameState.getHex(@urban.trade.x, @urban.trade.y)
                
                if @trade and @trade.trade_node

                    puts "trading with: #{@trade.trade_node.name}"
                    # puts @trade.inspect
                end

            end
        end

    end

end