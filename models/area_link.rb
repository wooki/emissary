require 'json'

module Emissary

class AreaLink

  attr_accessor :x, :y, :distance, :name

  def initialize
    super()    
  end

  def coord_sym
    "#{@x},#{@y}".to_sym
  end

  def coord
    {x: @x, y: @y}
  end

  def as_json(options={})
    {
      x: @x,
      y: @y,
      distance: @distance,
      name: @name
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
  

end

end
