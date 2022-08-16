require_relative "../rulesengine/rule"
require_relative "../rulesengine/turn_sequence"
require_relative '../constants'
require_relative '../rules/trade'

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
        def Execute(gameState)

            trades = Array.new

            if @urban and @urban.trade



            end

            trades
        end

    end

end