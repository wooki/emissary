require_relative './constants'
require_relative '../rules/behaviour/hiring'

module Emissary

class Area

  attr_accessor :x, :y, :terrain, :population,
    :food, :goods, :province, :trade_node, :info, :trade, :messages, :agents

  def initialize
    super()
    @info = Array.new
    @agents = Hash.new
    @messages = Array.new
  end

  def new_turn
    @info = Array.new
    @trade_node.new_turn if @trade_node and @trade_node.is_node
  end

  def name
    return "#{@trade_node.name} Trade" if trade_node and trade_node.is_node
    "#{@terrain} #{@x},#{y}"
  end

  def coord_sym    
    "#{@x},#{@y}".to_sym
  end

  def coord
    {x: @x, y: @y}
  end

  def add_agent(a)
    @agents[a.id] = a
  end

  def remove_agent(a)
    @agents.delete a.id
  end

  def message(msg, from)    
    @messages.push Message.new(message, from)
  end

  def hire_cost(game)
    Hiring.agent_hire_cost(3, self, game)
  end

  def report(level, player, game)
    
    details = {x: @x, y: @y, terrain: @terrain }

    details[:has_population] = !["ocean", "peak"].include?(@terrain)
    details[:province] = @province if @province
    details[:trade_node] = @trade_node if @trade_node

    details[:population] = @population if level >= INFO_LEVELS[:POPULATION]
    details[:messages] = @messages if level >= INFO_LEVELS[:MESSAGES]
    details[:hire_cost] = hire_cost(game) if level >= INFO_LEVELS[:WEALTH]

    details[:agents] = @agents.map { | agent | 
        agent.report(level)
    }.compact
    
    if level >= INFO_LEVELS[:PRODUCTION]
      details[:food] = @food
      details[:goods] = @goods
    end

    if @trade_node and @trade_node.is_node
      if level >= INFO_LEVELS[:TRADE]
        details[:trade_node] = @trade_node
      end
    end

    if @info and @info.length > 0
      details[:info] = @info.select do | info_item | 
        (!player.nil? and info_item[:player] == player) or info_item[:level] <= level
      end
    end

    details
  end  

end

end
