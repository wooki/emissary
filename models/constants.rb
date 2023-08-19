module Emissary

    # stores constants for each turn sequence
    PRODUCTION_FOOD_TRAVEL_LOSS = 0.95
    PRODUCTION_GOODS_TRAVEL_LOSS = 0.95
    FOOD_CONSUMPTION = 0.001
    INDUSTRY_RATE = 0.001
    TRADE_RATE = 0.10
    TRADE_RATE_TRAVEL = 0.01
    START_GOLD_PER_POPULATION = 0.002
    START_GOLD_MAX = 50

    INFO_LEVELS = {
        # level required to gain this info
        PRODUCTION: 2,
        TRADE: 4,
        INDUSTRY: 5,
        UPKEEP: 3,  
        POPULATION: 3,
        
        # what levels does each access have
        PUBLIC: 1,
        OWNED: 9
    }    
end