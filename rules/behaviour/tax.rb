require_relative '../../models/constants'
require_relative './industry_utilisation'

# based on the tax rate of the settlement raise gold based
# on utilised industry
module Emissary

    # decreases wealth
    class Tax

        # is increased when industry is fully utilised
        def self.industry(urban, gameState)

            if urban.tax > 0

                utilisation = IndustryUtilisation.check urban
                if utilisation >= 1
                    utilisation = 1

                    # generate gold and reduce wealth
                    gold = TAX_RATIO * urban.tax * utilisation
                    gold = gold.to_f * (1 + @urban.wealth).floor.to_i
                    urban.store.gold += gold
                    wealth_reduction = TAX_WEALTH_REDUCTION * urban.tax * urban.industry * utilisation
                    urban.add_wealth(0 - wealth_reduction)
                    gameState.info "TAX", urban, "Tax was collected from industry", {gold: gold}
                    gameState.info "WEALTH", urban, "Wealth drecreased by #{wealth_reduction} due to tax on industry", {wealth: wealth_reduction}
                end

            end

        end

    end
        

end