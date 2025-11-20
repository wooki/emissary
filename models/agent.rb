require_relative './constants'
require_relative '../rules/behaviour/hiring'

module Emissary

class Agent

  attr_accessor :id, :x, :y, :owner, :range, :depth, :skill, :messages, :next_payment

  def initialize(id)
    super()
    @id = id
    @messages = Array.new
    @range = 1
    @depth = 1
    @skill = 1
    @next_payment = 0    
  end  

  def new_turn
    @messages = Array.new    
  end

  def coord_sym    
    "#{@x},#{@y}".to_sym
  end

  def coord
    {x: @x, y: @y}
  end

  def message(msg, from)    
    @messages.push Message.new(msg, from)
  end

  def level 
    Math.sqrt(@range + @depth + @skill)
  end

  def cost(area, game)
    Hiring.agent_hire_cost(self.level, area, game)
  end

  def report(level, player, area, game)
    
    is_owner = player == @owner

    if !is_owner and level < ((10 + @skill) - (@range + @depth)) and level < INFO_LEVELS[:FULL] 
      return nil
    end

    details = {id: @id, x: @x, y: @y}

    details[:owner] = @owner if level >= @skill or is_owner
    details[:range] = @range if level >= INFO_LEVELS[:FULL] or is_owner
    details[:depth] = @depth if level >= INFO_LEVELS[:FULL] or is_owner
    details[:skill] = @skill if level >= INFO_LEVELS[:FULL] or is_owner
    details[:level] = level if level >= INFO_LEVELS[:FULL] or is_owner
    details[:next_payment] = @next_payment if level >= INFO_LEVELS[:FULL] or is_owner
    details[:cost] = self.cost(area, game) if level >= INFO_LEVELS[:FULL] or is_owner
    
    details[:messages] = @messages if level >= INFO_LEVELS[:MESSAGES] or is_owner

    details
  end  

end

end
