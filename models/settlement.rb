require_relative './area'
require_relative './store'
require_relative './constants'
require_relative '../rules/behaviour/hiring'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :store, :neighbours,
                :wealth, :borders, :tax, :trade_policy, :coast

  def initialize
    super()
    @store = Store.new
    @neighbours = Array.new
    @wealth = 0
    @tax = 0.0

    # policy can be 
    # :none = don't buy or sell
    # :ration = buy/sell up to half upkeep and industy
    # :trade = buy/sell up to upkeep and industy
    # :reserve = buy/sell up to upkeep*2 and industy*2 will only buy at most 200% of req
    # :stockpile = upkeep/industy x3
    # :hoard = upkeep/industy x5 
    @trade_policy = { :food => :trade, :goods => :trade }
  end

  def wealth_percentage
    1 + (@wealth * 0.01)
  end

  def wealth_percentage_ten_percent
    1 + (@wealth * 0.001)
  end

  def industry
    (@population.to_f * INDUSTRY_RATE * wealth_percentage).floor
  end

  def upkeep_food
    (@population.to_f * FOOD_CONSUMPTION).round
  end

  def trade_policy_modifier(resource)
    if @trade_policy[resource] == :none
      0      
    elsif @trade_policy[resource] == :ration
      0.5
    elsif @trade_policy[resource] == :reserve
      2
    elsif @trade_policy[resource] == :stockpile
      3
    elsif @trade_policy[resource] == :hoard
      5
    else
      1
    end
  end

  def import_message(resource)
    verb = "feed population"
    verb = "match industrial capacity" if resource == :goods 

    if @trade_policy[resource] == :none
      "No #{resource.to_s} imported due to import policy"      
    elsif @trade_policy[resource] == :ration
      "#{resource.to_s.capitalize} imported to partially #{verb}"
    elsif @trade_policy[resource] == :trade
      "#{resource.to_s.capitalize} imported to #{verb}"
    else
      "#{resource.to_s.capitalize} imported to #{verb} and build #{@trade_policy[resource]}"
    end    
  end      

  def name
    @name
  end

  def name=(val)
    @name = val
  end

  def add_wealth(val)
    @wealth = 0 if !@wealth
    @wealth = @wealth + val
    @wealth = 0 if @wealth < 0
  end

  def province_name
    @name 
  end

  def hire_cost(game)
    Hiring.agent_hire_cost(3, self, game)
  end 

  def report(level, player, game)

    #set level to full if reporting to owner
    is_owner = player == @owner        

    details = super(level, player, game, is_owner)

    details.delete(:food)
    details.delete(:goods)

    details[:owner] = @owner if level >= INFO_LEVELS[:KNOWN] or is_owner
    details[:name] = @name
    details[:coast] = @coast
    details[:borders] = @borders if level >= INFO_LEVELS[:KNOWN] or is_owner

    details[:report_level] = level
    details[:report_level] = INFO_LEVELS[:FULL] if is_owner
    
    # add details dependent on level
    details[:hire_cost] = hire_cost(game) if level >= INFO_LEVELS[:WEALTH] or is_owner
    details[:trade] = @trade #if level >= INFO_LEVELS[:TRADE]
    details[:wealth] = @wealth.round(2) if level >= INFO_LEVELS[:WEALTH] or is_owner
    details[:tax] = @tax.round() if level >= INFO_LEVELS[:PRODUCTION] or is_owner
    details[:trade_policy] = @trade_policy if level >= INFO_LEVELS[:POLICY] or is_owner

    if level >= INFO_LEVELS[:STORE] or is_owner
      details[:store] = @store
    end

    details
  end  


end

end
