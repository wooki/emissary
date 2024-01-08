require_relative '../../models/constants'
require_relative './industry_utilisation'

# Behaviours are intended to be referenced from other rules and do a small thing
# for example Wealth microrule is called from many other rules and contains logic
# for updating wealth property based on behaviour in those rules, implementation is
# left open to accomodate all sorts of uses
module Emissary

    # effects the amount of industry a settlement has, more wealth = more industry
    # increases the cost payed when buying goods or food by increasing the trade_rate by 10% of the wealth
    #
    # is increased when industry is fully utilised
    # is increased when food or goods are exported
    # is reduced when industry is not fully utilised
    # is reduced when food upkeep is not met
    # increases gold generated from tax
    # is reduced by tax rate
    
    # TODO    
    # increases the cost of recruiting armies
    # when wealth is high guilds may seize power (wealth & tax rate combine for this check)
    # is reduced when gold < 0 (code below has been added but not being called, needs specific rule)
    # is reduced when armies are recruited
    class Wealth



        # is increased when industry is fully utilised
        def self.industry(urban, gameState)

            if urban

                utilisation = IndustryUtilisation.check urban
                if utilisation >= 1
                    # increase wealth and add message
                    urban.add_wealth(WEALTH_INDUSTRY)
                    gameState.info "WEALTH", urban, "Wealth increased by #{WEALTH_INDUSTRY} due to industry utilisation", {wealth: WEALTH_INDUSTRY}
                elsif utilisation < 1
                    # decrease by 5*standard if entirely unused and proprotionaly
                    decrease = (5 * WEALTH_INDUSTRY) * (1 - utilisation)
                    urban.add_wealth(0 - decrease)
                    gameState.info "WEALTH", urban, "Wealth decreased by #{decrease} due to industrial decline", {wealth: 0 - decrease}
                end

            end

        end

        # is increased when food or goods are exported
        def self.exported(urban, total_exported, gameState)

            if urban

                if total_exported > 0
                    # increase wealth and add message
                    increase = (total_exported.to_f * WEALTH_EXPORT_RATE).round(4)
                    if increase > 0

                        urban.add_wealth(increase)
                        gameState.info "WEALTH", urban, "Wealth increased by #{increase} due to export of goods and food", {wealth: increase}
                    end
                end

            end

        end

        # is reduced when gold < 0
        def bankrupt(urban, gameState)

            if urban
                if urban.store.gold <= 0

                    # decrease wealth and add message
                    urban.add_wealth(0 - WEALTH_BANKRUPT)
                    gameState.info "WEALTH", urban, "Wealth decreased by #{WEALTH_BANKRUPT} as the state is brankrupt", {wealth: 0 - WEALTH_BANKRUPT}

                end
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