require_relative '../rules/production'

module Emissary

  # dynamically creates rules and populates their
  # properties from the "raw" version being passed
  # in
  class RuleFactory

    # map orders to rules
    def initialize

      @rules = {
        "production" => Production
      }

    end

    def CreateRule(orderName, parameters, player, gameState)

      parameters = Array.new if parameters == nil

      # look-up the Rule object from the orderName
      ruleClass = @rules[orderName.downcase]

      # check if ruleName is invalid
      if ! ruleClass then
        gameState.OrderError(player, 'No rule could be found for order: ' + orderName)
        return
      end

      # create an instance
      begin
        newRule = ruleClass.new(player)
      rescue
        puts 'rule class not found for: ' + ruleClass + ": " + $!
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