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

            if @urban and @urban[:trade]

                # how many food and goods do we need to import
                food_required = (@urban[:population].to_f * FOOD_CONSUMPTION).floor.to_i
                goods_required = (@urban[:population].to_f * INDUSTRY_RATE).floor.to_i
                distance = @urban[:trade][:distance]

                @trade = gameState.getHex(@urban[:trade][:x], @urban[:trade][:y])
                if @trade and @trade[:trade] and @trade[:trade][:is_node]

                    puts "trading with: #{@trade[:trade][:name]}"
                    puts "food_required: #{food_required}, goods:#{goods_required}"

                end

            end
        end

    end

end