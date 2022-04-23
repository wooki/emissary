module Emissary

class Area

   attr_accessor :x, :y, :belongs_to, :name, :terrain

   ##################################
   # set-up initial state
   ##################################
   def initialize
      super()

      @belongs_to = nil # user_id
      @terrain = nil
      @x = nil
      @y = nil
      @name = nil

      @units = Array.new
   end

   # get this area as a hash
   def to_h
      {:x => @x, :y => @y, :terrain => @terrain, :belongs_to => @belongs_to, :name => @name}
   end

   ##################################
   # gets the adjacent coords for this area
   # that are x distance away, obeying map size
   ##################################
   def adjacent(dist, map, map_size)
      areas = []
      coords = MapUtils::adjacent(self.to_h, map_size)
      coords.each { | coord |
         areas.push map["#{coord[:x]},#{coord[:y]}"]
      }
      areas
   end

end

end
