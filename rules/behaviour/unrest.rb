require_relative '../../models/constants'
require_relative './industry_utilisation'

# Behaviours are intended to be referenced from other rules and do a small thing
# for example Wealth microrule is called from many other rules and contains logic
# for updating wealth property based on behaviour in those rules, implementation is
# left open to accomodate all sorts of uses
module Emissary

    # when unrest is high there may be a peasant revolt
    # reduced the availability of soliders for recruitment
    #
    # is increased when food upkeep is not met
    # is increased when armies are recruited
    # is reduced when food upkeep is  met
    # is reduced when army is present
    # is increased when wealth is very high
    class Unrest

        def metUpkeep(urban, gameState)

            if urban
            end
        end

        # is reduced when food upkeep is not met
        def failedUpkeep(urban, unrest, gameState)

            if urban

                if unrest > 0

                    # decrease wealth and add message
                    decrease = unrest.to_f * WEALTH_FAILED_UPKEEP_RATE * urban.population.to_f
                    urban.add_wealth(0 - decrease)
                    gameState.info "WEALTH", urban, "Wealth decreased by #{decrease} following food shortage", {wealth: 0 - decrease}

                end
            end
        end

    end

end