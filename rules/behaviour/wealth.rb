require_relative '../../models/constants'
require_relative './industry_utilisation'

# Behaviours are intended to be referenced from other rules and do a small thing
# for example Wealth microrule is called from many other rules and contains logic
# for updating wealth property based on behaviour in those rules, implementation is
# left open to accomodate all sorts of uses
module Emissary::Behaviours

    # increases the cost payed when buying goods or food
    # increases gold generated from tax
    #
    # is increased when industry is fully utilised
    # is increased when food or goods are exported
    # is reduced by tax rate
    # is reduced when industry is not fully utilised
    # is reduced when armies are recruited
    # is reduced when food upkeep is not met
    # is reduced when gold < 0
    class Wealth

        # wealth is increased when industry is fully utilised
        def self.industry(urban)

            if urban

                utilisation = IndustryUtilisation.check urban
                if utilisation >= 1
                    puts "Wealth: #{urban.name} utilisation=#{utilisation} UTILISED"
                else
                    puts "Wealth: #{urban.name} utilisation=#{utilisation}"
                end

            end

        end

    end

end