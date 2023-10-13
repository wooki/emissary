require_relative '../../models/constants'
require_relative './industry_utilisation'

# Behaviours are intended to be referenced from other rules and do a small thing
# for example Wealth microrule is called from many other rules and contains logic
# for updating wealth property based on behaviour in those rules, implementation is
# left open to accomodate all sorts of uses
module Emissary

    # when unrest is high there may be a peasant revolt
    # reduced the availability of soliders for recruitment
    # DONE reduces foood and goods production
    #
    # DONE is increased when food upkeep is not met
    # is increased when armies are recruited
    # DONE is reduced when food upkeep is  met
    # is reduced when army is present
    # DONE is increased when wealth is very high
    class Unrest

        def self.wealth(urban, gameState)
            # TODO: need to check this in it's own rule (or attached to UNREST check)

            if urban

                # calculate unrest level based on "high" wealth
                unrest = ((urban.wealth ** UNREST_INEQUALITY_EXPONENT).to_f * UNREST_INEQUALITY_RATE).round(4)

                if unrest > 0

                    # increase unrest and add message
                    urban.add_unrest(increase)
                    gameState.info "UNREST", urban, "Unrest increased by #{increase} due to inequality between the workers and the elites", {unrest: increase}

                end
            end
        end

        def self.metUpkeep(urban, gameState)

            if urban

                # decrease unrest and add message
                decrease = UNREST_MET_UPKEEP_RATE
                urban.add_unrest(0 - decrease)
                gameState.info "UNREST", urban, "Unrest decreased by #{decrease} following normal food supply", {unrest: 0 - decrease}

            end
        end

        # is reduced when food upkeep is not met
        def self.failedUpkeep(urban, unrest, gameState)

            if urban

                if unrest > 0

                    # increase unrest and add message
                    increase = unrest.to_f * UNREST_UNMET_UPKEEP_RATE
                    urban.add_unrest(increase)
                    gameState.info "UNREST", urban, "Unrest increased by #{increase} following food shortage", {unrest: increase}

                end
            end
        end

    end

end