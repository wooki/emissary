module Wraithdale

require 'json'
require 'optparse'
require 'fantasynamegenerator'
require File.expand_path(File.dirname(__FILE__) + '/map_utils.rb')

#
# Class for creating a random map
#
class MapGenerator

   attr_accessor :seed

   def initialize(seed=nil)

      @fng_euro = FantasyNameGenerator.BuiltIn "north_euro_place"
      @fng_spanish = FantasyNameGenerator.BuiltIn "spanish_place"

      @seed = seed
      @seed = Random.new_seed if !@seed
      @random = srand @seed

      # some variables for generation, usually # per size
      @mountain_ranges = 0.2
      @mountain_chance = 150
      @peek_chance = 40
      @plains_chance = 350
      @rivers = 0.35
      @river_bend = 50
      @deserts = 0.1
      @deserts_chance = 4000
      @deserts_region = 0.2
      @deserts_region_offset = 0.4
      @forests = 18
      @forests_chance = 50
      @extra_plains = @forests*2
      @extra_plains_region = 0.15
      @extra_plains_chance = 35
      @ocean_edge = 0.15
      @ocean_middle = 0.25
      @city_min_distance = 8
      @city_max_distance = 16
      @town_min_distance = 3
      @town_max_distance = 6
      @edge_ocean_chances = [100, 80, 50, 20]
      @city_away_from_edge = 10
      @town_away_from_edge = 3
      @trade_node_min_size = 13
      @trade_node_sample_size = 15
      @trade_node_land_multiplier = 3

      # store the map as we build it
      @map = Hash.new

   end

   # actual generate a map
   def generate(size)

      # remember size
      @size = size

      # adjust generation parameters by area assuming these
      # are for 100X100 map
      area = @size*size
      areafactor = area.to_f / (100*100).to_f
      areafactor = 0.5 if areafactor < 0.5 # hardcoded minimum to ensure we get items on small maps

      @mountain_ranges = @mountain_ranges * areafactor
      @rivers = @rivers * areafactor
      @deserts = @deserts * areafactor
      @forests = @forests * areafactor
      @extra_plains = @extra_plains * areafactor
      @trade_node_min_size = @trade_node_min_size * areafactor
      @trade_node_sample_size = 20 - (@trade_node_sample_size * areafactor).round
      @trade_node_sample_size = 1 if @trade_node_sample_size < 1


      # adjust for a more land-based map
      # @mountain_chance = 300
      # @plains_chance = 900

      # adjust for a more island based map
      # @mountain_ranges = 0.3
      # @mountain_chance = 70
      # @plains_chance = 150

      # start by creating a ocean world
      MapUtils::mapcoords(size) { | x, y |
         @map["#{x},#{y}"] = {
            x: x,
            y: y,
            terrain: 'ocean'
         }
      }

      # raise several mountains and enlarge them outwards
      mountain_ranges_to_gen = (@mountain_ranges * size).round
      (1..mountain_ranges_to_gen).each { | x |

         # get a coord within range of the center
         allowed_distance_edge = (size/2).round - ((size/2).round * @ocean_edge)
         allowed_distance_middle = ((size/2).round * @ocean_middle)
         summit = nil
         while summit == nil
            summit = MapUtils::randcoord(size)
            if allowed_distance_edge < MapUtils::distance(summit, {:x => (size/2).round, :y => (size/2).round})
               summit = nil
            elsif allowed_distance_middle > MapUtils::distance(summit, {:x => (size/2).round, :y => (size/2).round})
               summit = nil
            end
         end

         # make summit a mountain and then each adjacent area
         # recursively has a chance
         @map["#{summit[:x]},#{summit[:y]}"][:terrain] = 'mountain'
         coords = MapUtils::adjacent(summit, size)
         coords.each { | coord |
            make_terrain(coord, size, ['ocean'], 'mountain', @mountain_chance)
         }
      }

      # make mountains peeks if they are completely surrounded by mountains and 0-1 other peek
      mountains = get_terrain('mountain')
      mountains.each { | mountain |
         if can_be_peek(mountain, size)
            if rand(0..100) <= @peek_chance
               mountain[:terrain] = 'peek'
            end
         end
      }

      # raise plains around the mountain ranges
      mountains = get_terrain('mountain')
      mountains.each { | mountain |
         coords = MapUtils::adjacent(mountain, size)
         coords.each { | coord |
            make_terrain(coord, size, ['ocean'], 'plains', @plains_chance)
         }
      }

      # before creating rivers turn any single area of ocean into forest
      oceans = get_terrain('ocean')
      oceans.each { | ocean |
         has_ocean_adjacent = false
         coords = MapUtils::adjacent(ocean, size)
         coords.each { | coord |
            has_ocean_adjacent = has_ocean_adjacent || @map["#{coord[:x]},#{coord[:y]}"][:terrain] == 'ocean'
         }
         if !has_ocean_adjacent
            @map["#{ocean[:x]},#{ocean[:y]}"][:terrain] = 'forest'
         end
      }

      # raise forests randomly around
      forests_to_gen = (@forests * size).round
      forests = get_terrain('plains').sample(forests_to_gen)
      forests.each { | forest |
         make_terrain(forest, size, ['plains'], 'forest', @forests_chance)
      }

      # randomly add an area of desert
      deserts_to_gen = (@deserts * size).round
      from_y = ((size/2) - (size*@deserts_region)).round + (@deserts_region_offset*@size)
      to_y = ((size/2) + (size*@deserts_region)).round + (@deserts_region_offset*@size)

      deserts = get_terrain_in_region(['plains', 'forest'], {:from => {:x => 0, :y => from_y}, :to => {:x => size, :y => to_y}}).sample(deserts_to_gen)
      deserts.each { | desert |
         make_terrain(desert, size, ['plains', 'forest'], 'desert', @deserts_chance)
      }


      # randomly add an area of plains within middle region to reduce forests
      extra_plains_to_gen = (@extra_plains * size).round
      from_y = ((size/2) - (size*@extra_plains_region)).round
      to_y = ((size/2) + (size*@extra_plains_region)).round

      extra_plains = get_terrain_in_region(['forest'], {:from => {:x => 0, :y => from_y}, :to => {:x => size, :y => to_y}}).sample(extra_plains_to_gen)
      extra_plains.each { | extra_plain |
         make_terrain(extra_plain, size, ['plains', 'forest'], 'plains', @extra_plains_chance)
      }

      # make edges ocean
      @edge_ocean_chances.each_index { | edge_ocean_chance_index |
         @map.each { | key, hex |
            if hex[:x] <= 0 or hex[:x] >= size or
               hex[:y] <= 0 or hex[:y] >= size or
               MapUtils::distance(hex, {:x => (size/2).round, :y => (size/2).round}) > (size/2).round-(edge_ocean_chance_index+1)

               if rand(0..100) <= @edge_ocean_chances[edge_ocean_chance_index]
                  hex[:terrain] = 'ocean'
               end
            end
         }
      }

      # create rivers from mountains to the sea
      rivers_to_gen = (@rivers * size).round
      @existing_rivers = Array.new
      river_sources = get_terrain('mountain').sample(rivers_to_gen)
      river_sources.each { | river |

         # find the closest edge and move in that direction 70% of the time
         # but go sideways 30% - until you reach ocean!
         # river_direction = closest_terrain_direction(river, 'ocean', size)
         river_direction = closest_ocean_direction(river, size)
         make_river(river, size, river_direction)

      }

      # create cities on areas are suitable and
      # the required distance from any other city
      allowed_settlement_terrain = get_terrain(['plains', 'forest', 'mountain', 'desert']).shuffle
      settlements = Array.new
      allowed_settlement_terrain.each { | plain |
         if can_be_city(plain, size, settlements)
            plain[:terrain] = 'city'
            plain[:required_distance] = rand(@city_min_distance..@city_max_distance)
            settlements.push plain
         end
      }

      # adjust all cities to allow closer towns
      settlements.map! { | v |
         v[:required_distance] = rand(@town_min_distance..@town_max_distance)
         v
      }

      # create towns
      allowed_settlement_terrain.each { | plain |
         if can_be_town(plain, size, settlements)
            plain[:terrain] = 'town'
            plain[:required_distance] = rand(@town_min_distance..@town_max_distance)
            settlements.push plain
         end
      }

      # name settlements
      all_names = Hash.new
      settlements.each { | settlement |

         path = find_closest_terrain(settlement, 'desert', size)
         distance = path.length
         n = nil

         while n == nil do
            if distance < 3
               n = @fng_spanish.random(1).first
            else
               n = @fng_euro.random(1).first
            end

            n = nil if all_names.has_key? n
         end

         settlement[:name] = n
      }

      # create trade nodes in large bodies of water
      trade_nodes = possible_trade_nodes(size)

      # add trade node to map and find closest town/city for name
      trade_nodes.each { | hex |
         hex = getHex(hex[:x], hex[:y])

         settlement_found = lambda do | coord, path |
            mapcoord = getHex(coord[:x], coord[:y])
            ["city", "town"].include? mapcoord[:terrain] and mapcoord[:trade].nil?
         end

         can_be_traversed = lambda do | coord, path, is_first |
            mapcoord = getHex(coord[:x], coord[:y])
            ["city", "town", "ocean"].include? mapcoord[:terrain]
         end

         # we won't have a path because we aren't going anywhere specific
         path_to_closest = MapUtils::breadth_search({:x => hex[:x], :y => hex[:y]}, size, can_be_traversed, settlement_found)
         closest = getHex(path_to_closest.last[:x], path_to_closest.last[:y])
         hex[:trade] = {
            :name => "#{closest[:name]} Trade Node",
            :is_node => true
         }
      }

      # assign each town/city to closest trade node via ocean
      get_terrain(['city', 'town']).each { | hex |

         tradenode = nil

         tradenode_found = lambda do | coord, path |
            if is_trade_node?(coord)
               tradenode = getHex(coord[:x], coord[:y])
            else
               false
            end
         end

         can_be_traversed = lambda do | coord, path, is_first |
            mapcoord = getHex(coord[:x], coord[:y])
            if is_first
               ["city", "town", "ocean"].include? mapcoord[:terrain]
            else
               ["ocean"].include? mapcoord[:terrain]
            end
         end

         path_to_closest = MapUtils::breadth_search({:x => hex[:x], :y => hex[:y]}, size, can_be_traversed, tradenode_found)
         if path_to_closest
            hex[:trade] = {
               :x => tradenode[:x],
               :y => tradenode[:y],
               :name => tradenode[:trade][:name],
               :distance => path_to_closest.length
            }
         end
      }

      # assign each town/city that isn't attached via ocean to the closest attached
      get_terrain(['city', 'town']).each { | hex |

         if hex[:trade].nil?

            tradenode = nil

            tradenode_found = lambda do | coord, path |
               if is_trade_node?(coord)
                  tradenode = getHex(coord[:x], coord[:y])
               else
                  false
               end
            end

            can_be_traversed = lambda do | coord, path, is_first |
               mapcoord = getHex(coord[:x], coord[:y])
               !(["peek", "mountain"].include? mapcoord[:terrain])
            end

            path_to_closest = MapUtils::breadth_search({:x => hex[:x], :y => hex[:y]}, size, can_be_traversed, tradenode_found)
            if path_to_closest
               hex[:trade] = {
                  :x => tradenode[:x],
                  :y => tradenode[:y],
                  :name => tradenode[:trade][:name],
                  :distance => path_to_closest.length * @trade_node_land_multiplier
               }
            end
         end
      }

      # connect every trade node to closest two it connects to via ocean
      trade_nodes.each { | hex |
         hex = getHex(hex[:x], hex[:y])

         closest = nil
         path_to_closest = nil
         second_closest = nil
         path_to_second_closest = nil

         tradenode_found = lambda do | coord, path |
            mapcoord = getHex(coord[:x], coord[:y])

            if is_trade_node?(coord) and mapcoord != hex

               if !closest.nil? and second_closest.nil?
                  path_to_second_closest = path
                  second_closest = mapcoord
                  second_closest[:trade][:connected] = Array.new if !second_closest[:trade][:connected]
                  second_closest[:trade][:connected].push({
                     :name => hex[:trade][:name],
                     :x => hex[:x],
                     :y => hex[:y],
                     :distance => path.length
                  })
                  second_closest[:trade][:connected].uniq!
               elsif closest.nil?
                  path_to_closest = path
                  closest = mapcoord
                  closest[:trade][:connected] = Array.new if !closest[:trade][:connected]
                  closest[:trade][:connected].push({
                     :name => hex[:trade][:name],
                     :x => hex[:x],
                     :y => hex[:y],
                     :distance => path.length
                  })
                  closest[:trade][:connected].uniq!
               end

            else
               false
            end

            (!closest.nil? and !second_closest.nil?)
         end

         can_be_traversed = lambda do | coord, path, is_first |
            mapcoord = getHex(coord[:x], coord[:y])
            ["city", "town", "ocean"].include? mapcoord[:terrain]
         end

         MapUtils::breadth_search({:x => hex[:x], :y => hex[:y]}, size, can_be_traversed, tradenode_found)

         if closest
            hex[:trade][:connected] = Array.new if !hex[:trade][:connected]
            hex[:trade][:connected].push({
               :name => closest[:trade][:name],
               :x => closest[:x],
               :y => closest[:y],
               :distance => path_to_closest.length
            })
            if second_closest
               hex[:trade][:connected].push({
                  :name => second_closest[:trade][:name],
                  :x => second_closest[:x],
                  :y => second_closest[:y],
                  :distance => path_to_second_closest.length
               })
            end
            hex[:trade][:connected].uniq!
         end

         # puts hex.inspect
      }


      # rivers would be great for map making but not so practival for game making
      # maybe leave for now!

      # systematically find rivers (ocean with exactly two adjacent oceans that are not adjacent themselves)
      # convert to river and follow in both directions converting to river until the rule breaks - a river
      # with a coastline and one adjacent river becomes a river mouth (river terrain but graphically different)
      # TODO - on hold

      # find lakes - ocean surrounded by non-ocean. may have adjacent rivers.
      # TODO

      # find islands - non-ocean surrounded by ocean
      # TODO

      # find all ocean and set coast edges of adjacent not ocean
      # TODO

      # Trade nodes need to allow river travel if the above is added


      # set population and production
      # population = 20k for city, 10k for town
      # adjacent terrain gives bonus

      # other terrain all have a base level
      # adjacent to city/town, 2 away from city/town

      # production is skewed towards food/goods

      # production of each boosted by adjacent terrain



      # remove some side-effect keys e.g. :z and :required_distance

      @map
   end

   def getHex(x, y)
      @map["#{x},#{y}"]
   end

   def is_trade_node?(coords)
      hex = getHex(coords[:x], coords[:y])
      hex[:trade] and hex[:trade][:is_node]
   end

   def getTradeNode(coords)
      hex = getHex(coords[:x], coords[:y])
      if hex[:trade] and trade[:x] and trade[:y]
         getHex trade[:x], trade[:y]
      else
         nil
      end
   end


   # finds all ocean hexs that are surrounded by ocean in all directions by at
   # least @trade_node_min_size
   def possible_trade_nodes(size)

      # only ever check a certain distance
      max_range = 2 * @trade_node_min_size

      # get all water that is completely surrounded by water
      # then reduce list as much as possible for speed
      possible_nodes = get_terrain('ocean').filter { | hex |
         adj = count_terrain(MapUtils::adjacent(hex, size))
         adj['ocean'] == 6
      }

      # any near edge will be found anyway - so safe to remove a lot
      possible_nodes.filter! { | hex |
         dist_from_middle = MapUtils::distance(hex, {:x => (size/2).round, :y => (size/2).round})
         dist_from_middle < (size/2).round-4
      }

      # just remove 1 in X nodes in the list - will be found anyway
      possible_nodes = possible_nodes.shuffle.each_slice(@trade_node_sample_size).map(&:first)

      # find all possible trade nodes (blocks of ocean)
      possible_nodes = possible_nodes.map { | hex |
         possible_trade_node(hex, size, max_range)
      }
      possible_nodes.compact!

      # order by number of times that center hex appears and then by size
      possible_nodes.sort! { | a, b |
         count_a = possible_nodes.filter { | x | x[:x] == a[:x] and x[:y] == a[:y] }.length
         count_b = possible_nodes.filter { | x | x[:x] == b[:x] and x[:y] == b[:y] }.length
         if count_a == count_b
            a[:hexes].length <=> b[:hexes].length
         else
            count_a <=> count_b
         end
      }
      possible_nodes.reverse!

      # remove any subsequent nodes that appear in an earlier block
      possible_nodes.filter! { | node |
         found = false

         node_index = possible_nodes.index { | n | n[:x] == node[:x] and n[:y] == node[:y] }

         better_nodes = possible_nodes.slice(node_index + 1, possible_nodes.length)

         if better_nodes.length > 0
            better_nodes.each { | better_node |

               if better_node[:x] == node[:x] and better_node[:y] == node[:y]
                  found = true
               elsif better_node[:hexes].index { | n | n[:x] == node[:x] and n[:y] == node[:y] }
                  found = true
               end
            }
         end

         !found
      }
   end

   # find the ocean area around a hex and check if center is ocean
   def possible_trade_node(start, size, max_range)

      # search continues up to a reasonable max
      is_found = lambda do | coord, path |
         false # never found in this use
      end

      # remember all hexs
      searched_hexes = Array.new
      can_be_traversed = lambda do | coord, path, is_first |
         # exclude once we hit a max range from start
         distance = MapUtils::distance(coord, {:x => start[:x], :y => start[:y]})
         return false if distance > max_range

         # check terrain
         mapcoord = @map["#{coord[:x]},#{coord[:y]}"]
         can_traverse = mapcoord[:terrain] == 'ocean'
         searched_hexes.push(mapcoord) if can_traverse

         can_traverse
      end

      # we won't have a parh because we aren't going anywhere specific
      MapUtils::breadth_search({:x => start[:x], :y => start[:y]}, size, can_be_traversed, is_found)

      # check center
      max_x = searched_hexes.reduce(0) do | sum, hex |
         sum + hex[:x]
      end
      max_y = searched_hexes.reduce(0) do | sum, hex |
         sum + hex[:y]
      end
      center_x = (max_x.to_f / searched_hexes.length.to_f).round
      center_y = (max_y.to_f / searched_hexes.length.to_f).round

      # not allowed if not ocean and surrounded by ocean
      center_hex = getHex(center_x, center_y)
      return nil if center_hex[:terrain] != 'ocean'
      adj = count_terrain(MapUtils::adjacent(center_hex, size))
      return nil if adj['ocean'] != 6

      # return center point and hexes that it contains
      return {
         :x => center_x,
         :y => center_y,
         :hexes => searched_hexes
      };

   end

   # check if this area is suitable for a town
   # 1+ ocean and 2+ plains/forest
   def can_be_town(coord, size, existing_settlements)

      # check adjacent terrain
      adj = count_terrain(MapUtils::adjacent(coord, size))
      if (adj['desert'] >= 3 and
          adj['ocean'] >= 1) or
         (adj['ocean'] >= 1 and
          adj['plains'] >= 1 and
          adj['plains']+adj['forest'] >= 3)

         # check if too close to edge
         if MapUtils::distance(coord, {:x => (size/2).round, :y => (size/2).round}) >= (size/2).round-@town_away_from_edge
            return false
         end

         # check existing villages not too close
         existing_settlements.each { | village |
            if (village[:x] - coord[:x]).abs <= village[:required_distance] and
               (village[:y] - coord[:y]).abs <= village[:required_distance]
               return false
            end
         }
         true
      else
         false
      end
   end

   # check if this area is suitable for a city
   # 1+ ocean and 2+ plains/forest
   def can_be_city(coord, size, existing_settlements)

      # check adjacent terrain
      adj = count_terrain(MapUtils::adjacent(coord, size))
      if (adj['desert'] >= 3 and
          adj['ocean'] >= 1) or
         (adj['ocean'] >= 1 and
          adj['plains'] >= 1 and
          adj['forest'] >= 1 and
          adj['plains']+adj['forest'] >= 3)

         # check if too close to edge
         if MapUtils::distance(coord, {:x => (size/2).round, :y => (size/2).round}) >= (size/2).round-@city_away_from_edge
            return false
         end

         # check existing villages not too close
         existing_settlements.each { | village |
            if (village[:x] - coord[:x]).abs <= village[:required_distance] and
               (village[:y] - coord[:y]).abs <= village[:required_distance]
               return false
            end
         }
         true
      else
         false
      end
   end

   # check if this area is suitable for a peek
   # all mountain, optionally 1 peek adjacent
   def can_be_peek(coord, size)

      # check adjacent terrain
      adj = count_terrain(MapUtils::adjacent(coord, size))
      if adj['mountain'] == 6 or
         (adj['mountain'] == 5 and
          adj['peek'] == 1)

         true
      else
         false
      end
   end

   # util for counting terrain types
   def count_terrain(coords)

      total = {'ocean' => 0, 'town' => 0, 'plains' => 0,
               'mountain' => 0, 'forest' => 0, 'desert' => 0,
               'peek' => 0, 'city' => 0, 'river' => 0 }

      coords.each { | coord |
         mapcoord = @map["#{coord[:x]},#{coord[:y]}"]
         total[mapcoord[:terrain]] += 1
      }

      total
   end

   # try and make this area a mountain and then check any
   # adjacent area
   def make_terrain(coord, size, from_terrains, to_terrain, chance)

      if from_terrains.include? @map["#{coord[:x]},#{coord[:y]}"][:terrain]
         if rand(0..100) <= chance
            @map["#{coord[:x]},#{coord[:y]}"][:terrain] = to_terrain
            coords = MapUtils::adjacent(coord, size)
            coords.each { | coord |
               make_terrain(coord, size, from_terrains, to_terrain, chance*0.75)
            }
         end
      end

   end

   # make this area a river and then move in transform direction (or bend sometimes)
   def make_river(coord, size, transform, ocean_count=0)

      map_area = @map["#{coord[:x]},#{coord[:y]}"]
      return if !map_area

      # don't allow peeks to be converted
      if map_area[:terrain] == 'peek'
         return false
      end

      # handle meeting ocean is tricky. If we hit another river then stop.
      # If we hit 2+ ocean in a row stop otherwise carry one.
      if map_area[:terrain] == 'ocean'
         return false if @existing_rivers.include? "#{coord[:x]},#{coord[:y]}"
         ocean_count += 1
         return true if ocean_count > 1
      else
         ocean_count = 0
      end

      result = true
      if rand(0..100) <= @river_bend
         if rand(0..100) <= 49
            result = make_river(MapUtils::transform_coord(coord, MapUtils::rotate_transform(transform)), size, transform, ocean_count)
         else
            result = make_river(MapUtils::transform_coord(coord, MapUtils::rotate_transform_by(transform, 5)), size, transform, ocean_count)
         end
      else
         result = make_river(MapUtils::transform_coord(coord, transform), size, transform, ocean_count)
      end

      if result
         map_area[:terrain] = 'ocean'
         @existing_rivers = Array.new if !@existing_rivers
         @existing_rivers.push "#{coord[:x]},#{coord[:y]}"
      end
      result
   end

   # get all terrain of one type
   def get_terrain(terrain)
      if !terrain.kind_of? Array
         terrain = [terrain]
      end

      coords = Array.new
      @map.each { | key, value |
         if terrain.include? value[:terrain]
            coords.push(value)
         end
      }
      coords
   end


   # get all terrain of one type from within a region
   def get_terrain_in_region(terrain, region)
      coords = Array.new
      @map.each { | key, hex |
         if hex[:x] >= region[:from][:x] and
            hex[:x] <= region[:to][:x] and
            hex[:y] >= region[:from][:y] and
            hex[:y] <= region[:to][:y]

            if !terrain.kind_of? Array
               terrain = [terrain]
            end
            if terrain.include? hex[:terrain]
               coords.push(hex)
            end
         end
      }
      coords
   end


   # find the direction of closest terrain of certain type
   # and return as a transform
   # def closest_terrain_direction(coord, terrain, size, exclude=[])

   #    path = find_closest_terrain(coord, terrain, size, exclude)

   #    # get transform of first step if there is one
   #    if path and path.length > 0

   #       first = path.first
   #       {
   #          :x => (first[:x] - coord[:x]),
   #          :y => (first[:y] - coord[:y])
   #       }

   #    else
   #       nil
   #    end
   # end

   # find the direction of closest ocean surrounded by ocean (i.e. skip rivers!)
   def closest_ocean_direction(start, size, exclude=[])

      terrain_found = lambda do | coord, path |
         mapcoord = getHex(coord[:x], coord[:y])
         if mapcoord[:terrain] == 'ocean'

            adj = count_terrain(MapUtils::adjacent(coord, size))
            adj['ocean'] == 6

         else
            false
         end
      end

      path = MapUtils::breadth_search({:x => start[:x], :y => start[:y]}, size, nil, terrain_found, exclude)

      # get transform of first step if there is one
      if path and path.length > 0

         first = path.first
         {
            :x => (first[:x] - start[:x]),
            :y => (first[:y] - start[:y])
         }

      else
         nil
      end
   end

   def find_closest_terrain(start, terrain, size, exclude=[])

      terrain_found = lambda do | coord, path |
         mapcoord = getHex(coord[:x], coord[:y])
         mapcoord[:terrain] == terrain
      end

      return MapUtils::breadth_search({:x => start[:x], :y => start[:y]}, size, nil, terrain_found, exclude)
   end

   # output as svg
   def to_svg(hexsize=100, io)

      hex_b = 2*Math.sin( 60*(Math::PI/180) )*hexsize
      xoffset = (hex_b/2).round + MapUtils::hex_pos(0, (@size/2).round, hexsize, 0, 0)[:x].abs
      yoffset = hexsize*1.25
      canvassize_x = ((@size+1) * hex_b).round
      canvassize_y = hexsize * 1.5 * (@size + 2)

      io.print "<?xml version=\"1.0\"?>"
      io.print "<!-- SEED: \"#{@seed}\" -->"
      io.print "<svg width=\"#{canvassize_x}\" height=\"#{canvassize_y}\""
      io.print " viewPort=\"0 0 #{canvassize_x} #{canvassize_y}\" version=\"1.1\""
      io.print " xmlns=\"http://www.w3.org/2000/svg\">\n"
      io.print "<rect width=\"#{canvassize_x}\" height=\"#{canvassize_y}\" fill=\"#3D59AB\"/>"

      # create icons
      io.print "<symbol id=\"trade\" width=\"#{hexsize}\" height=\"#{hexsize}\" viewBox=\"0 0 512 512\">"
      io.print '<path xmlns="http://www.w3.org/2000/svg" d="M203.97 23l-18.032 4.844 11.656 43.468c-25.837 8.076-50.32 21.653-71.594 40.75L94.53 80.594l-13.218 13.22 31.376 31.374c-19.467 21.125-33.414 45.53-41.813 71.343l-42.313-11.343-4.843 18.063 42.25 11.313c-6.057 27.3-6.157 55.656-.345 83L23.72 308.78l4.843 18.064 41.812-11.22c6.693 21.225 17.114 41.525 31.25 59.876l-29.97 52.688-16.81 29.593 29.56-16.842 52.657-29.97c18.41 14.216 38.784 24.69 60.094 31.407l-11.22 41.844 18.033 4.81 11.218-41.905c27.345 5.808 55.698 5.686 83-.375l11.312 42.28 18.063-4.81-11.344-42.376c25.812-8.4 50.217-22.315 71.342-41.78l31.375 31.373 13.22-13.218-31.47-31.47c19.09-21.266 32.643-45.738 40.72-71.563l43.53 11.657 4.813-18.063-43.625-11.686c5.68-27.044 5.576-55.06-.344-82.063l43.97-11.78-4.813-18.063L440.908 197c-6.73-20.866-17.08-40.79-31.032-58.844l29.97-52.656 16.842-29.563-29.593 16.844-52.656 29.97c-17.998-13.875-37.874-24.198-58.657-30.906l11.783-44L309.5 23l-11.78 43.97c-27-5.925-55.02-6.05-82.064-.376L203.97 23zm201.56 85L297.25 298.313l-.75.437-40.844-40.875-148.72 148.72-2.186 1.25 109.125-191.75 41.78 41.78L405.532 108zm-149.686 10.594c21.858 0 43.717 5.166 63.594 15.47l-116.625 66.342-2.22 1.28-1.28 2.22-66.25 116.406c-26.942-52.04-18.616-117.603 25.03-161.25 26.99-26.988 62.38-40.468 97.75-40.468zm122.72 74.594c26.994 52.054 18.67 117.672-25.002 161.343-43.66 43.662-109.263 52.005-161.312 25.033l116.438-66.282 2.25-1.25 1.25-2.25 66.375-116.592z" />'
      io.print '</symbol>'

      io.print "<symbol id=\"town\" width=\"#{hexsize}\" height=\"#{hexsize}\" viewBox=\"0 0 512 512\">"
      io.print '<path xmlns="http://www.w3.org/2000/svg" d="M109.902 35.87l-71.14 59.284h142.28l-71.14-59.285zm288 32l-71.14 59.284h142.28l-71.14-59.285zM228.73 84.403l-108.9 90.75h217.8l-108.9-90.75zm-173.828 28.75v62h36.81l73.19-60.992v-1.008h-110zm23 14h16v18h-16v-18zm265 18v10.963l23 19.166v-16.13h16v18h-13.756l.104.087 19.098 15.914h-44.446v14h78v-39h18v39h14v-62h-110zm-194.345 48v20.08l24.095-20.08h-24.095zm28.158 0l105.1 87.582 27.087-22.574v-65.008H176.715zm74.683 14h35.735v34h-35.735v-34zm-76.714 7.74L30.37 335.153H319l-144.314-120.26zm198.046 13.51l-76.857 64.047 32.043 26.704H481.63l-108.9-90.75zm-23.214 108.75l.103.086 19.095 15.914h-72.248v77.467h60.435v-63.466h50v63.467h46v-93.466H349.516zm-278.614 16V476.13h126v-76.976h50v76.977h31.565V353.155H70.902zm30 30h50v50h-50v-50z" />'
      io.print '</symbol>'

      io.print "<symbol id=\"city\" width=\"#{hexsize}\" height=\"#{hexsize}\" viewBox=\"0 0 512 512\">"
      io.print '<path xmlns="http://www.w3.org/2000/svg" d="M255.95 27.11L180.6 107.614l150.7 1.168-75.35-81.674h-.003zM25 109.895v68.01l19.412 25.99h71.06l19.528-26v-68h-14v15.995h-18v-15.994H89v15.995H71v-15.994H57v15.995H39v-15.994H25zm352 0v68l19.527 26h71.06L487 177.906v-68.01h-14v15.995h-18v-15.994h-14v15.995h-18v-15.994h-14v15.995h-18v-15.994h-14zm-176 15.877V260.89h110V126.63l-110-.857zm55 20.118c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zM41 221.897V484.89h78V221.897H41zm352 0V484.89h78V221.897h-78zM56 241.89c4 0 8 4 8 12v32H48v-32c0-8 4-12 8-12zm400 0c4 0 8 4 8 12v32h-16v-32c0-8 4-12 8-12zm-303 37v23h-16v183h87v-55c0-24 16-36 32-36s32 12 32 36v55h87v-183h-16v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14zm-49 43c4 0 8 4 8 12v32H96v-32c0-8 4-12 8-12zm72 0c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zm80 0c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zm80 0c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zm72 0c4 0 8 4 8 12v32h-16v-32c0-8 4-12 8-12zm-352 64c4 0 8 4 8 12v32H48v-32c0-8 4-12 8-12zm400 0c4 0 8 4 8 12v32h-16v-32c0-8 4-12 8-12z"/>'
      io.print '</symbol>'

      # assign each trade node a color
      colors = ['mediumvioletred', 'indigo', 'darkviolet', 'midnightblue', 'saddlebrown', 'chocolate', 'maroon', 'deeppink'].shuffle
      trade_node_colors = Hash.new
      @map.each { | key, hex |
         if is_trade_node? hex
            trade_node_colors[key] = colors.pop
         end
      }

      @map.each { | key, hex |

         terrain = hex[:terrain]
         if terrain == "peek"
            # terrain = "silver"
            terrain_color = "dimgray"
         elsif terrain == "ocean"
            if is_trade_node? hex
               # terrain_color = hex[:tradenode]
               # terrain_color = "blueviolet"
               terrain_color = trade_node_colors[key]
            else
               terrain_color = "#3D59AB"
            end
         elsif terrain == "mountain"
            terrain_color = "slategray"
         elsif terrain == "plains"
            terrain_color = "limegreen"
         elsif terrain == "forest"
            terrain_color = "forestgreen"
         elsif terrain == "desert"
            terrain_color = "goldenrod"
         elsif terrain == "town"
            terrain_color = "black"
         elsif terrain == "city"
            terrain_color = "red"
         end

         pos = MapUtils::hex_pos(hex[:x], hex[:y], hexsize, xoffset, yoffset)
         hexsizes = MapUtils::hexsizes(hexsize)
         hex_points = MapUtils::hex_points(pos[:x], pos[:y], hexsize)

         io.print "<polygon points=\""
         hex_points.each { | hex_point |
            io.print "#{hex_point[:x].round(2)},#{hex_point[:y].round(2)} "
         }
         # io.print "\" fill=\"#{terrain_color}\" stroke=\"#{terrain_color}\" />"
         # io.print "\" fill=\"#{terrain_color}\" stroke=\"black\" stroke-width=\"0.5\" />"
         stroke = "black"
         stroke_width= 0.1
         if !is_trade_node?(hex) and hex[:trade]
            # stroke = trade_node_colors["#{hex[:trade][:x]},#{hex[:trade][:y]}"]
            # stroke_width = 2.0
            terrain_color = trade_node_colors["#{hex[:trade][:x]},#{hex[:trade][:y]}"]
         end
         io.print "\" fill=\"#{terrain_color}\" stroke=\"#{stroke}\" stroke-width=\"#{stroke_width}\" />"

         x = pos[:x].to_f - (hexsize.to_f/2).to_f
         y = pos[:y].to_f - (hexsize.to_f/2).to_f
         if terrain == "town"
            io.print "<use href=\"#town\" x=\"#{x.round(2)}\"  y=\"#{y.round(2)}\" fill=\"white\" style=\"opacity:1.0\" />"
         elsif terrain == "city"
            io.print "<use href=\"#city\" x=\"#{x.round(2)}\"  y=\"#{y.round(2)}\" fill=\"white\" style=\"opacity:1.0\" />"
         elsif terrain == "ocean" and is_trade_node? hex
            io.print "<use href=\"#trade\" x=\"#{x.round(2)}\"  y=\"#{y.round(2)}\" fill=\"black\" style=\"opacity:0.8\" />"
         end

         # io.print "<text font-size=\"8px\" x=\"#{x}\" y=\"#{pos[:y]}\" fill=\"white\">#{hex[:x]},#{hex[:y]}</text>"
      }

      # town and city labels
      @map.each { | key, hex |

         if hex[:terrain] == "city" or hex[:terrain] == "town" or
            (hex[:terrain] == "ocean" and is_trade_node? hex)

            pos = MapUtils::hex_pos(hex[:x], hex[:y], hexsize, xoffset, yoffset)
            hexsizes = MapUtils::hexsizes(hexsize)
            hex_points = MapUtils::hex_points(pos[:x], pos[:y], hexsize)

            x = hex_points[2][:x].round(2)
            y = hex_points[2][:y].round(2)
            color = "black"

            font_size = '20px'
            font_size = '14px' if hex[:terrain] == "town"

            text = hex[:name]
            text = hex[:trade][:name] if text.nil?
            io.print "<text font-size=\"#{font_size}\" x=\"#{x}\" y=\"#{y}\" fill=\"#{color}\">#{text}</text>"

         end
      }

      # debug searched path
      if @debug_hexes

         @debug_hexes.uniq!

         @debug_hexes.each { | hex |

            if hex[:tradenode].nil? && hex[:trade].nil?
               pos = MapUtils::hex_pos(hex[:x], hex[:y], hexsize, xoffset, yoffset)
               hexsizes = MapUtils::hexsizes(hexsize)
               hex_points = MapUtils::hex_points(pos[:x], pos[:y], hexsize)

               io.print "<polygon points=\""
               hex_points.each { | hex_point |
                  io.print "#{hex_point[:x].round(2)},#{hex_point[:y].round(2)} "
               }
               io.print "\" fill=\"magenta\" fill-opacity=\"0.2\" />"
            end
         }
      end

      io.print "</svg>"
   end
end

end



# parse command line options
options = {
   size: 100,
   hexsize: 18
}
OptionParser.new do | opts |
   opts.banner = "Usage: map_generator.rb [options]"

   # input json file

   opts.on("-fFILE", "--fileout=FILE", "File to write map to") do |n|
     options[:file] = n
   end

   opts.on("-sSEED", "--seed=SEED", "Seed for random generation") do |n|
     options[:seed] = n.to_i
   end

   opts.on("-FFORMAT", "--format=FORMAT", "SVG or JSON") do |n|
     options[:format] = n
   end

   opts.on("-SSIZE", "--size=SIZE", "Width and height of the map") do |n|
     options[:size] = n.to_i
   end

   opts.on("-hHEXSIZE", "--hesize=HEXSIZE", "Size to draw each hex in the Svg") do |n|
     options[:hexsize] = n.to_i
   end
end.parse!

seeded = nil
seeded = options[:seed]
mg = Wraithdale::MapGenerator.new seeded

map = mg.generate options[:size]

if options[:file] and options[:format] == "json"
   $stdout.print "#{mg.seed}"
   File.open(options[:file], 'w') do | file |
      file.print map.to_json
   end
elsif options[:format] == "json"

   print map.to_json

elsif options[:file]
   File.open(options[:file], 'w') do | file |
      mg.to_svg options[:hexsize], file
   end
else
   mg.to_svg options[:hexsize], $stdout
end

# pipe seed from json gen to svg so we get same map twice
# bundle exec ruby map_generator.rb -f map.json -F json -S 100 -h 16 | xargs -I % sh -c 'bundle exec ruby map_generator.rb -f map.svg -S 100 -h 16 --seed=%'


