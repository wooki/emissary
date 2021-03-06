module Emissary

require 'json'

class GameState

  attr_accessor :kingdoms, :map, :my_kingdom, :settlements, :turn

  def initialize
    super()

    # keyed by user id
    @kingdoms = Hash.new

    # keyed by "x,y" (areas contain units)
    @map = Hash.new

    @turn = 0
  end

  def self.load(gamefile)
    # load the gamestate
    data = File.read(gamefile)
    self.from_json(data)
  end

  def self.from_json(json)
    hash = JSON.parse(json, {:symbolize_names => true})
    state = GameState.new
    state.turn = hash[:turn]
    state.map = hash[:map]
    state.kingdoms = hash[:kingdoms]
    state.my_kingdom = hash[:my_kingdom]
    state.load_settlements
    state
  end

  def getHex(x, y)
    @map["#{x},#{y}".to_sym]
 end

  # work out the largest x/y dimension
  def size
    largest = 0
    @map.each { | key, hex |
      largest = hex[:x] if hex[:x] > largest
      largest = hex[:y] if hex[:y] > largest
    }
    largest
  end

  # shortcut to settlements in the map hash based on unique
  # short strings
  def load_settlements

    @settlements = Hash.new

    # iterate settlements and assign shortcuts to each
    @map.each { | key, hex |

      if ['town', 'city'].include? hex[:terrain]

        if hex[:shortcut]
          code = hex[:shortcut]
          shortcut_help = hex[:shortcut_help]

        elsif hex[:name].include? " "
          parts = hex[:name].downcase.split
          code = parts.collect { | part | part[0, 1] }.join
          shortcut_help = parts.collect { | part | part[0, 1].upcase + part[1, 99].downcase }.join(' ')

          if @settlements.include? code.to_sym
            code = parts[0][0,1] + parts[1][0,2]
            shortcut_help = parts[0][0,1].upcase + parts[0][1, 99].downcase + " " + parts[1][0,2].upcase + parts[1][2, 99].downcase
          end

          if @settlements.include? code.to_sym
            code = parts[0][0,2] + parts[1][0,1]
            shortcut_help = parts[0][0,2].upcase + parts[0][2, 99].downcase + " " + parts[1][0,1].upcase + parts[1][1, 99].downcase
          end

          if @settlements.include? code.to_sym
            code = parts.collect { | part | part[0, 2] }.join
            shortcut_help = parts.collect { | part | part[0, 2].upcase + part[2, 99].downcase }.join(' ')
          end

          if @settlements.include? code.to_sym
            code = parts[0][0,2] + parts[1][0,3]
            shortcut_help = parts[0][0,2].upcase + parts[0][2, 99].downcase + " " + parts[1][0,3].upcase + parts[1][3, 99].downcase
          end
        else

          code = hex[:name][0, 3].downcase
          shortcut_help =  hex[:name][0, 3].upcase +  hex[:name][3, 99].downcase

          if @settlements.include? code.to_sym
            code = hex[:name][0, 4].downcase
            shortcut_help =  hex[:name][0, 4].upcase +  hex[:name][4, 99].downcase
          end

          if @settlements.include? code.to_sym
            code = hex[:name][0, 5].downcase
            shortcut_help =  hex[:name][0, 5].upcase +  hex[:name][5, 99].downcase
          end

          if @settlements.include? code.to_sym
            code = hex[:name].downcase
            shortcut_help =  hex[:name].upcase
          end
        end

        hex[:shortcut] = code.to_sym
        hex[:shortcut_help] = shortcut_help.to_sym
        @settlements[code.to_sym] = key

      end
    }

  end

  # find a settlement with a short version of the name
  def find_settlement(name_fragment)
    coord = @settlements[name_fragment]
    if coord
      @map[coord]
    else
      nil
    end
  end

  def kingdom_by_name(name)
    @kingdoms.values.find { | kingdom | kingdom[:name] == name }
  end

  def kingdom_by_player(name)

    @kingdoms[name]
  end

  def kingdom_by_capital(coord)
    @kingdoms.values.find { | kingdom | kingdom[:x] == coord[:x] and kingdom[:y] == coord[:y] }
  end

  def rural
    ['lowland', 'mountain', 'forest', 'desert']
  end

  def urban
    ['town', 'city']
  end

  # get all of the specified terrain from the map
  # and return array - if block then only include
  # items where block returns true
  def each_area(terrain)
    matched = []
    terrain = [terrain] if !terrain.kind_of? Array

    @map.each { | key, value |
      if terrain.include? value[:terrain]
        if !block_given? or yield value
          matched.push value
        end
      end
    }
    matched
  end

  def each_rural
    self.each_area self.rural
  end

  def each_urban
    self.each_area self.urban
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
  # clears old data and increments
  # turn
  ##################################
  def new_turn(randomseed)

    # clear old data
    puts "clearing old data"
    @messages = Array.new

  	# reset planets
  	# self.each_planet { | planet |
  	# 	planet.new_turn
  	# }

    # reset ships
  	# self.each_ship { | ship |
  	# 	ship.new_turn
  	# }

  	 # increment turn no
    @turn = @turn.next
    puts "moving to turn #{@turn}"

    # ensure we can repeat rand calls by logging
    # and allowing the reuse of a seed
    if randomseed == nil or randomseed == ''
  		randomseed = rand(1000000)
  		puts "random seed generated: #{randomseed}"
  		@randomseed = randomseed
	 	else
			puts "random seed set to: #{randomseed}"
			@randomseed = randomseed
	 	end
	 	srand(@randomseed)

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



  def as_json(options={})
  # :kingdoms, :map, :my_kingdom
      data = {
        :kingdoms => @kingdoms,
        :map => @map,
        :turn => @turn
      }
      data[:my_kingdom] = @mykingdom if !@my_kingdom.nil?
      data
    end

    def to_json(*options)
        as_json(*options).to_json(*options)
    end

    def save(gamefile)
      # save the gamestate
      File.open(gamefile, 'w') do | file |
        file.print JSON.pretty_generate(self)
      end
    end

end

end
