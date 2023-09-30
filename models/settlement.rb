require_relative './area'
require_relative './store'
require_relative './constants'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :store, :neighbours,
                :wealth, :guilds, :borders

  def initialize
    super()
    @store = Store.new
    @neighbours = Array.new
    @wealth = 0
    @guilds = 0
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

  def add_guild_power(val)
    @guilds = 0 if !@guilds
    @guilds = @guilds + val
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
    details[:guilds] = @guilds.round(2) if level >= INFO_LEVELS[:GUILDS]

    if level >= INFO_LEVELS[:STORE]
      details[:store] = @store
    end

    details
  end

  def guilds
    # when guild power is high they may seize power
    #
    # increases the cost payed when buying goods or food
    # increases the cost of recruiting armies
    #
    # is increased by tax rate
    # is increased when industry is fully utilised
    # is increased when food or goods are exported
    # is increased when gold < 0
    # is reduced when industry is not fully utilised
    # is reduced when army is present

  end

  def unrest
    # when unrest is high there may be a peasant revolt
    #
    # is increased when food upkeep is not met
    # is increased when armies are recruited
    # is reduced when food upkeep is  met
    # is reduced when army is present

  end

  def tax
    # player can set rate, they generate gold from industry.  10% tax = 1 gold from 10 utilised industry
    #
    # reduces wealth
    # increases guilds

  end



end

end
