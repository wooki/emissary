require_relative '../../models/constants'
require_relative './industry_utilisation'

# Behaviours are intended to be referenced from other rules and do a small thing
# for example guild_power microrule is called from many other rules and contains logic
# for updating guild_power property based on behaviour in those rules, implementation is
# left open to accomodate all sorts of uses
module Emissary

    # when guild power is high they may seize power
    #
    # increases the cost payed when buying goods or food
    # increases the cost of recruiting armies
    #
    # is increased by tax rate
    # DONE is increased when industry is fully utilised
    # is increased when food or goods are exported
    # is increased when gold < 0
    # DONE is reduced when industry is not fully utilised
    # is reduced when army is present
    class Guilds

        # is increased when industry is fully utilised
        def self.industry(urban, gameState)

            if urban

                utilisation = IndustryUtilisation.check urban
                if utilisation >= 1
                    # increase guild_power and add message
                    urban.add_guild_power(GUILDS_INDUSTRY)
                    gameState.info "GUILDS", urban, "Guild power increased by #{GUILDS_INDUSTRY} due to industry utilisation", {guilds: GUILDS_INDUSTRY}
                elsif utilisation < 1
                    # decrease by 2*standard if entirely unused and proprotionaly
                    decrease = (2 * GUILDS_INDUSTRY) * (1 - utilisation)
                    urban.add_guild_power(0 - decrease)
                    gameState.info "GUILDS", urban, "Guild power decreased by #{decrease} due to industrial decline", {guilds: 0 - decrease}
                end

            end

        end

        # # is increased when food or goods are exported
        # def self.exported(urban, total_exported, gameState)

        #     if urban

        #         if total_exported > 0
        #             # increase guild_power and add message
        #             increase = (total_exported.to_f * guild_power_EXPORT_RATE).round(4)
        #             if increase > 0

        #                 urban.add_guild_power(increase)
        #                 gameState.info "guild_power", urban, "guild_power increased by #{increase} due to export of goods and food", {guild_power: increase}
        #             end
        #         end

        #     end

        # end

        # # is reduced when gold < 0
        # def bankrupt(urban, gameState)

        #     if urban
        #         if urban.store.gold <= 0

        #             # decrease guild_power and add message
        #             urban.add_guild_power(0 - guild_power_BANKRUPT)
        #             gameState.info "guild_power", urban, "guild_power decreased by #{guild_power_BANKRUPT} as the state is brankrupt", {guild_power: 0 - guild_power_BANKRUPT}

        #         end
        #     end
        # end


    end

end