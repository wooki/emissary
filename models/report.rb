module Emissary

require 'json'

class Report

  attr_accessor :kingdoms, :map, :my_kingdom, :turn

  def initialize
    super()

    # keyed by user id
    @kingdoms = Hash.new
    @my_kingdom = nil

    # keyed by "x,y" (areas contain units)
    @map = Hash.new

    @turn = 0    

  end  

  def as_json(options={})
  
    # :kingdoms, :map, :my_kingdom
      data = {
        :kingdoms => @kingdoms,
        :map => @map,
        :turn => @turn
      }
      data[:my_kingdom] = @my_kingdom if !@my_kingdom.nil?
      data
    end

    def to_json(*options)
        as_json(*options).to_json(*options)
    end    

end

end
