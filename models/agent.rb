require_relative './constants'

module Emissary

class Agent

  attr_accessor :id, :x, :y, :owner, :range, :depth, :skill, :messages

  def initialize(id)
    super()
    @id = id
    @messages = Array.new
    @range = 1
    @depth = 1
    @skill = 1
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

  def report(level, player)
    
    is_owner = player == @owner

    if !is_owner and level > ((10 + @skill) - (@range + @depth)) and level < INFO_LEVELS[:FULL] 
      return nil
    end

    details = {id: @id, x: @x, y: @y}

    details[:owner] = @owner if level >= @skill or is_owner
    details[:range] = @range if level >= INFO_LEVELS[:FULL] or is_owner
    details[:depth] = @depth if level >= INFO_LEVELS[:FULL] or is_owner
    details[:skill] = @skill if level >= INFO_LEVELS[:FULL] or is_owner
    
    details[:messages] = @messages if level >= INFO_LEVELS[:MESSAGES] or is_owner

    details
  end  

end

end
