module Emissary
  class Kingdom
    attr_accessor :player, :name, :capital, :capital_coord, :flag

    ##################################
    # set-up initial state
    ##################################
    def initialize
      super()

      @player = nil
      @name = nil
      @capital = nil
      @flag = nil
      @capital_coord = { x: nil, y: nil }
    end

    def x=

    def capital_coord_sym
      "#{@capital_coord[:x]},#{@capital_coord[:y]}".to_sym
    end

    def as_json(_options = {})
      {
        player: @player,
        name: @name,
        capital: @capital,
        flag: @flag,
        capital_coord: @capital_coord
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
