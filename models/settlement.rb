require_relative './area'
require_relative './store'
require_relative './constants'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :store, :neighbours,
                :wealth, :unrest, :borders, :tax, :trade_policy

  def initialize
    super()
    @store = Store.new
    @neighbours = Array.new
    @wealth = 0
    @unrest = 0
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

  def add_unrest(val)
    @unrest = 0 if !@unrest
    @unrest = @unrest + val
    @unrest = 0 if @unrest < 0
  end

  def report(level)
    details = super(level)

    details.delete(:food)
    details.delete(:goods)

    details[:owner] = @owner
    details[:name] = @name
    details[:borders] = @borders

    # add details dependent on level
    details[:trade] = @trade #if level >= INFO_LEVELS[:TRADE]
    details[:wealth] = @wealth.round(2) if level >= INFO_LEVELS[:WEALTH]
    details[:unrest] = @unrest.round(2) if level >= INFO_LEVELS[:UNREST]
    details[:tax] = @tax.round() if level >= INFO_LEVELS[:PRODUCTION]
    details[:trade_policy] = @trade_policy if level >= INFO_LEVELS[:POLICY]

    if level >= INFO_LEVELS[:STORE]
      details[:store] = @store
    end

    details
  end  


end

end
