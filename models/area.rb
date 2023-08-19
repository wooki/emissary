require_relative './constants'

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

  def coord_sym
    "#{@x},#{@y}".to_sym
  end

  def coord
    {x: @x, y: @y}
  end

  def report(level)
    
    details = {x: @x, y: @y, terrain: @terrain, closest_settlement: @closest_settlement, trade_node: @trade_node}
    details[:population] = @population if level >= INFO_LEVELS[:POPULATION]
    
    if level >= INFO_LEVELS[:PRODUCTION]
      details[:food] = @food
      details[:goods] = @goods
    end

    details
  end

end

end
