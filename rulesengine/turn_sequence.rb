module Emissary

    # stores constants for each turn sequence, changing
    # values here will re-arrange the turn sequence
    #

    TS_PRODUCTION = 10

    TS_MESSAGE = 20
    TS_COLONISE = 30
    TS_MOVE = 40
    TS_INTERCEPT = 50
    TS_REPAIR = 60
    TS_COMBAT = 70
    TS_BUILD = 80
    TS_UPGRADE = 90
    TS_MINING = 100
    TS_RESEARCH = 110
    TS_DISCOVERY = 120
    TS_NAME = 130 # must be last in case any orders used old name

end