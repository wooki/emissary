module Emissary

  # dynamically creates rules and populates their
  # properties from the "raw" version being passed
  # in
  class RuleFactory

    # map orders to rules
    def initialize

      @ruleClassNames = {
        "repair" => "RepairRule",
        "diplomacy" => "DiplomacyRule",
        "message" => "MessageRule",
        "name" => "NameRule",
        "move" => "MoveRule" ,
        "intercept" => "InterceptRule" ,
        "combat" => "CombatRule" ,
        "mining" => "MiningRule" ,
        "build" => "BuildRule",
        "upgrade" => "UpgradeRule",
        "colonise" => "ColoniseRule",
        "colonize" => "ColoniseRule",
        "research" => "ResearchRule",
        "discovery" => "DiscoveryRule"
      }

      @ruleClassFiles = {
        "repair" => "repair_rule.rb",
        "diplomacy" => "diplomacy_rule.rb",
        "message" => "message_rule.rb",
        "name" => "name_rule.rb",
        "move" => "move_rule.rb",
        "intercept" => "intercept_rule.rb",
        "combat" => "combat_rule.rb",
        "mining" => "mining_rule.rb",
        "build" => "build_rule.rb",
        "upgrade" => "upgrade_rule.rb",
        "colonise" => "colonise_rule.rb",
        "colonize" => "colonise_rule.rb",
        "research" => "research_rule.rb",
        "discovery" => "discovery_rule.rb"
      }

    end

    def CreateRule(orderName, parameters, player, gameState)

      parameters = Array.new if parameters == nil

      # look-up the Rule object name from the orderName
      ruleName = @ruleClassNames[orderName.downcase]

      # check if ruleName is invalid
      if ! ruleName then
        gameState.OrderError(player, 'No rule could be found for order: ' + orderName)
        return
      end

      # make sure we have that class loaded
      require Global.code_path + 'rules' + Global.path_separator + @ruleClassFiles[orderName.downcase]

      # create an instance
      begin
        ruleClass = ObjectSpace.const_get(ruleName)
        newRule = ruleClass.new(player)
      rescue
        puts 'rule class not found for: ' + ruleName + ": " + $!
        return
      end

      # try and set each parameter
      begin
        parameters.each { | value | begin
          newRule.send(value[0].downcase + '=', value[1])
        end }
      rescue
        puts $!
        puts parameters.inspect
        gameState.OrderError(player, 'Invalid parameters for ' + orderName + ': ' + parameters.to_s)
        return
      end

      # return the rule
      return newRule
    end

  end

end