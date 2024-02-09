require_relative '../rules/set_trade_policy'
require_relative '../rules/hire_agent'

module Emissary
  # dynamically creates rules and populates their
  # properties from the "raw" version being passed
  # in
  # only for parsing input from players - no need to do this for internal
  class RuleFactory
    # map orders to rules
    def initialize
      @rules = {
        'trade_policy' => SetTradePolicy,
        'hire_agent' => HireAgent
      }
    end

    def CreateRule(orderName, parameters, player, gameState)
      parameters = [] if parameters.nil?

      # look-up the Rule object from the orderName
      ruleClass = @rules[orderName.downcase]

      # check if ruleName is invalid
      unless ruleClass
        gameState.order_error(player, 'No rule could be found for order: ' + orderName)
        return
      end

      # create an instance
      begin
        newRule = ruleClass.new(player)
      rescue StandardError
        puts 'rule class not found for: ' + ruleClass + ': ' + $!
        return
      end

      # try and set each parameter
      begin
        parameters.each do |value|
          newRule.send(value[0].downcase + '=', value[1])
        end
      rescue StandardError => se
        puts se.message
        puts parameters.inspect
        gameState.order_error(player, 'Invalid parameters for ' + orderName + ': ' + parameters.to_s)
        return
      end

      # return the rule
      newRule
    end
  end
end
