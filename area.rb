module Emissary

class Area

  attr_accessor :x, :y, :terrain, :population,
    :food, :goods, :closest_settlement, :trade_node, :info

  def initialize
    super()
    @info = Array.new
  end

  def new_turn
    @info = Array.new
  end

  def name
    "#{@terrain} #{@x},#{y}"
  end

end

end
