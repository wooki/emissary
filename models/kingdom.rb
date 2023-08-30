module Emissary

class Kingdom

  attr_accessor :player, :name, :capital, :capital_coord

  ##################################
  # set-up initial state
  ##################################
  def initialize
    super()

    @player = nil
    @name = nil
    @capital = nil
    @capital_coord = {:x => nil, :y => nil}

  end

  def capital_coord_sym
    "#{@capital_coord[:x]},#{@capital_coord[:y]}".to_sym
  end  

  def as_json(options={})
    {
      player: @player,
      name: @name,
      capital: @capital,
      capital_coord: @capital_coord
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

end

end
