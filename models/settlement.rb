require_relative './area'
require_relative './store'
require_relative './constants'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :trade, :store, :neighbours

  def initialize
    super()
    @store = Store.new
    @neighbours = Array.new
  end

  def industry
    (@population.to_f * INDUSTRY_RATE).floor
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

  def wealth

  end

  def guilds

  end

  def loyalty

  end

  def tax

  end

  def neighbours

  end

end

end
