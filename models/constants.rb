module Emissary

    # some game generation items
    START_GOLD_PER_POPULATION = 0.002
    START_GOLD_MAX = 50

    # used in turn sequence rules and behaviours
    PRODUCTION_FOOD_TRAVEL_LOSS = 0.95 # rate at which food is reduced per area between the production area and the settlement (represents cost of taransit)
    PRODUCTION_GOODS_TRAVEL_LOSS = 0.95 # rate at which goods are reduced per area between the production area and the settlement (represents cost of taransit)
    FOOD_CONSUMPTION = 0.001 # food consumption per population rounded to integer
    INDUSTRY_RATE = 0.001 # industry per population, rounded down to integer
    TRADE_RATE = 0.10 # fixed rate of trading
    TRADE_RATE_TRAVEL = 0.01 # rate of trading per distance between settlement and trade node
    WEALTH_INDUSTRY = 0.01 # fixed increase to wealth if industry fully used
    WEALTH_EXPORT_RATE = 0.0005 # wealth increase this per good/food exported rounded to 4 decimals
    WEALTH_BANKRUPT = 0.2 # reduced wealth a standard amount if crown has no gold in coffers
    UNREST_UNMET_UPKEEP_RATE = 0.02 # increase unrest a proportion of how much upkeep was failed by
    UNREST_MET_UPKEEP_RATE = 0.005 # decrease unrest a proportion of how much upkeep was failed by
    UNREST_INEQUALITY_RATE = 0.001 # scaling of actual unrest from calculated inequality
    UNREST_INEQUALITY_EXPONENT = 3 # power the wealth is raised to create exponential growth

    INFO_LEVELS = {
        # level required to gain this info
        PRODUCTION: 2,
        TRADE: 4,
        INDUSTRY: 5,
        UPKEEP: 3,
        POPULATION: 3,
        UNREST: 3,
        STORE: 6,
        WEALTH: 4,

        # spies will gain levels here as the expand their network
        # spy level should probably just equal this level

        # what levels does each access have
        PUBLIC: 1,
        OWNED: 9
    }
end