require_relative './constants'

module Emissary

class Agent

  attr_accessor :x, :y, :owner, :range, :depth, :skill, :messages

  def initialize
    super()
    @messages = Array.new
    @range = 0
    @depth = 0
    @skill = 0
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
    @messages.push Message.new(message, from)
  end

  def report(level)
    
    if level < [@range, @depth, @skill].min and level < INFO_LEVELS[:OWNED] return nil

    details = {x: @x, y: @y}

    details[:owner] = @owner if level >= @skill or level >= INFO_LEVELS[:OWNED]
    details[:range] = @range if level >= INFO_LEVELS[:OWNED]
    details[:depth] = @depth if level >= INFO_LEVELS[:OWNED]
    details[:skill] = @skill if level >= INFO_LEVELS[:OWNED]
    
    details[:messages] = @messages if level >= INFO_LEVELS[:MESSAGES]
    

    details
  end  

end

end
