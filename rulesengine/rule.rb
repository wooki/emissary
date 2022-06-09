module Emissary

  # class for all rules
  class Rule

    attr_accessor :player, :turnSequence, :systemrule

    # Constructor requires some basic info
    def initialize(player, turnSequence, systemrule=false)
      @player = player
      @turnSequence = turnSequence
      @systemrule = systemrule
    end

    # executes this rule against the gamestate
    def Execute(gameState)
      raise "Rule must implement an Execute method"
    end

    # compare rule using sequence
    def <=>(arg)
      return self.turnSequence - arg.turnSequence
    end

  end
end