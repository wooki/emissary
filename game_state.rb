module Emissary

require 'json'

class GameState

  attr_accessor :kingdoms, :map, :my_kingdom


  ##################################
  # find a random empty village, update to
  # this user and return it
  ##################################
  def random_unowned_village(user_id)

    villages = self.each_area('village') { | v |
      v.belongs_to == nil
    }
    villages.sample
  end

  ##################################
  # get all of the specified terrain from the map
  # and return array - if block then only include
  # items where block returns true
  ##################################
  def each_area(terrain)
    matched = []
    terrain = [terrain] if !terrain.kind_of? Array

    @map.each { | key, value |
      if terrain.include? value.terrain
        if !block_given? or yield value
          matched.push value
        end
      end
    }
    matched
  end

  ##################################
  # get the kingom object for specified user
  ##################################
  def kingdom_for_user(user_id)
    @kingdoms.each { | key, kingdom |
      return kingdom if kingdom.belongs_to == user_id
    }
    return nil
  end

  ##################################
  # check the kingdom/capital names unique
  ##################################
  def kingdom_names_unique(name, capital)
    @kingdoms.each { | key, kingdom |
      return false if kingdom.name.downcase.gsub!(/\s+/, "") == name.downcase.gsub!(/\s+/, "") or
                      kingdom.capital.downcase.gsub!(/\s+/, "") == capital.downcase.gsub!(/\s+/, "")
    }
    return true
  end

  ##################################
  # set-up initial state
  ##################################
  def initialize
    super()

    # keyed by user id
    @kingdoms = Hash.new

    # keyed by "x,y" (areas contain units)
    @map = Hash.new

  end

  ##################################
  # converts the map to an array suitible for rendering in rails as json
  ##################################
  def map_array()

    maparray = Array.new
    @map.each { | key, area |
      maparray.push area
    }
    maparray
  end

  ##################################
  # build the map based on 2d array of terrains
  ##################################
  def build_map(mapdata)

    @map = Hash.new
    mapdata.each { | key, value |

      # create and add an area
      area = Emissary::Area.new
      area.x = value[:x]
      area.y = value[:y]
      area.terrain = value[:terrain]
      area.name = "Unnamed #{area.terrain}" if area.terrain == 'village'
      newkey = "#{area.x},#{area.y}"
      @map[newkey] = area
    }

  end

  def as_json(options={})
  # :kingdoms, :map, :my_kingdom
      data = {
        :kingdoms => @kingdoms,
        :map => @map
      }
      data[:my_kingdom] = @mykingdom if !@my_kingdom.nil?
      data
    end

    def to_json(*options)
        as_json(*options).to_json(*options)
    end


end

end
