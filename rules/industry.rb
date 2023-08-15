require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../models/store'

module Emissary

    # all settlements produces 1 good for each good+1000 population they have
    class Industry < Rule

        attr_accessor :urban

        def initialize(urban)
            super(nil, TS_INDUSTRY, true)
            self.urban = urban
        end

        def Execute(gameState)

            if @urban

                new_goods = [@urban.industry, @urban.store.goods].min
                if new_goods > 0
                    @urban.store.goods = @urban.store.goods + new_goods
                    gameState.info "INDUSTRY", @urban, "Industry produced #{new_goods} Goods", {goods: new_goods}
                end

            end

        end

    end

end