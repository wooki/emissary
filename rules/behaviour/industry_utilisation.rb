require_relative '../../models/constants'

module Emissary

    # work out percentage of industry that is active
    class IndustryUtilisation

        def self.check(urban)

            if urban and urban.industry > 0
                # do we have at least as many good as industry
                utilisation = (urban.store.goods.to_f / urban.industry.to_f).floor.to_i
                utilisation = 0 if utilisation < 0
                utilisation = 1 if utilisation > 1
                utilisation
            else
                0
            end

        end

    end

end