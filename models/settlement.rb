require_relative './area'
require_relative './store'
require_relative './constants'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :store, :neighbours,
                :wealth, :unrest, :borders

  def initialize
    super()
    @store = Store.new
    @neighbours = Array.new
    @wealth = 0
    @unrest = 0
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

  def name
    @name
  end

  def name=(val)
    @name = val
  end

  def add_wealth(val)
    @wealth = 0 if !@wealth
    @wealth = @wealth + val
  end

  def add_unrest(val)
    @unrest = 0 if !@unrest
    @unrest = @unrest + val
  end

  def report(level)
    details = super(level)

    details.delete(:food)
    details.delete(:goods)

    details[:owner] = @owner
    details[:name] = @name
    details[:borders] = @borders

    # add details dependent on level
    details[:trade] = @trade if level >= INFO_LEVELS[:TRADE]
    details[:wealth] = @wealth.round(2) if level >= INFO_LEVELS[:WEALTH]

    if level >= INFO_LEVELS[:STORE]
      details[:store] = @store
    end

    details
  end

  def tax
    # player can set rate, they generate gold from industry.  10% tax = 1 gold from 10 utilised industry
    #
    # reduces wealth
    # increases likelyhood that guilds will seize power

  end



end

end
