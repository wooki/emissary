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
    @trade_node.new_turn if @trade_node and @trade_node.is_node
  end

  def name
    "#{@terrain} #{@x},#{y}"
  end

end

end
