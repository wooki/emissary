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

end

end
