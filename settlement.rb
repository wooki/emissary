require_relative './area'
require_relative './store'
require_relative './constants'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :trade, :store

  def initialize
    super()
    @store = Store.new
  end

  def industry
    (@population.to_f * INDUSTRY_RATE).floor
  end

  def name
    @name
  end

  def name=(val)
    @name = val
  end

end

end
