module Emissary

class MapUtils

    # cache this data
    @@hexsizes = nil

    # get coords adjacent to this hex
    def self.adjacent_coords(coord)
        coords = [
           {:x => coord[:x]-1, :y => coord[:y]},
           {:x => coord[:x], :y => coord[:y]+1},
           {:x => coord[:x]+1, :y => coord[:y]+1},
           {:x => coord[:x]+1, :y => coord[:y]},
           {:x => coord[:x], :y => coord[:y]-1},
           {:x => coord[:x]-1, :y => coord[:y]-1}
        ]
        coords
    end

    # gets the adjacent coords
    def self.adjacent(coord, size)
      coords = self.adjacent_coords(coord)
      coords.delete_if { | c |
         !self.mapcontains(size, c)
      }
      coords
   end

    # random coord
    def self.randcoord(size)
        coords = self.mapcoords(size).sample
    end

    # util for getting generic hex data
    def self.hexsizes(hexsize)
        # work out the dimensions of our hexs if we haven't already
        # http://www.rdwarf.com/lerickson/hex/
        if !@@hexsizes
            @@hexsizes = {
               :a => hexsize/2,
               :b => Math.sin( 60*(Math::PI/180) )*hexsize,
               :c => hexsize
            }

            # work out what that means for our sizing
            @@hexsizes[:y] = @@hexsizes[:a] + @@hexsizes[:c]
            @@hexsizes[:x] = 2*@@hexsizes[:b]
            @@hexsizes[:xodd] = 0-@@hexsizes[:b] # step back for if y is odd
         end
        @@hexsizes
    end

    # util for getting the centre position of a hex to plot
    def self.hex_pos(x, y, hexsize, xoffset, yoffset)

      hs = self.hexsizes(hexsize)
      position = {
         :x => xoffset + (hs[:x]*x) + ((y-1) * hs[:xodd]),
         :y => yoffset + (hs[:y]*y),
      }

      position
    end

    # get coords for the corners of a hex
    def self.hex_points(x, y, hexsize)

        hs = self.hexsizes(hexsize)
        [
            {:x => x, :y => y-hs[:c]},
            {:x => x+hs[:b], :y => y-hs[:a]},
            {:x => x+hs[:b], :y => y+hs[:a]},
            {:x => x, :y => y+hs[:c]},
            {:x => x-hs[:b], :y => y+hs[:a]},
            {:x => x-hs[:b], :y => y-hs[:a]}
         ]
    end

    # transform one coord with another
   def self.transform_coord(coord, transform)
      newcoord = Hash.new
      newcoord[:x] = coord[:x] + transform[:x]
      newcoord[:y] = coord[:y] + transform[:y]
      newcoord
   end

   # rotate a transformation once clockwise - probably only works for
   # vector +/- 1 from 0,0
   def self.rotate_transform(transform)

      if transform[:x] < 0 and transform[:y] < 0
         {:x => transform[:x], :y => 0}
      elsif transform[:x] < 0 and transform[:y] == 0
         {:x => 0, :y => 0 - transform[:x]}
      elsif transform[:x] == 0 and transform[:y] > 0
         {:x => transform[:y], :y => transform[:y]}
      elsif transform[:x] > 0 and transform[:y] > 0
         {:x => transform[:x], :y => 0}
      elsif transform[:x] > 0 and transform[:y] == 0
         {:x => 0, :y => 0 - transform[:x]}
      elsif transform[:x] == 0 and transform[:y] < 0
         {:x => transform[:y], :y => transform[:y]}
      else
         transform
      end

   end

   # rotate a transformation a number of steps clockwise
   def self.rotate_transform_by(transform, steps)
      (1..steps).each { | step |
         transform = self.rotate_transform(transform)
      }
      transform
   end

    # return transforms needed to move to each adjacent area
    # for hex there are no diagonals to worry about excluding
    def self.adjacent_transforms
        [
            {:x => 1, :y => 1},
            {:x => 0, :y => 1},
            {:x => -1, :y => 0},
            {:x => -1, :y => -1},
            {:x => 0, :y => -1},
            {:x => 1, :y => 0}
        ]
   end


   # calc distance between two coords using 3rd (implied) axis
   def self.distance(from, to)

      from[:z] = from[:y] - from[:x]
      to[:z] = to[:y] - to[:x]

      dx = (from[:x] - to[:x]).abs
      dy = (from[:y] - to[:y]).abs
      dz = (from[:z] - to[:z]).abs

      [dx, dy, dz].max
   end

   # check if a coord should be included
   def self.mapcontains(size, coord)
      halfsize = (size/2).round
      middlehex = {:x => halfsize, :y => halfsize}
      self.distance(coord, middlehex) <= halfsize
   end

   # iterate coords on a hexagon map
   def self.mapcoords(size)

      coords = Array.new
      halfsize = (size/2).round
      middlehex = {:x => halfsize, :y => halfsize}

      (0..size).each { | x |
         (0..size).each { | y |
            coord = {:x => x, :y => y}
            if self.distance(coord, middlehex) <= halfsize
               coords.push coord
               yield x, y if block_given?
            end
         }
      }
      coords
   end

   # keep transforming coord until terrain type found and return
   # the distance
   def find_terrain_by_transform(start, transform, terrain, size, exclude=[])

      # move one coord
      nextcoord = MapUtils::transform_coord(start, transform)

      return nil if !nextcoord
      if exclude.include? "#{nextcoord[:x]},#{nextcoord[:y]}"
         return nil
      end

      # check for desired terrain
      return nil if !MapUtils::mapcontains(size, {x: nextcoord[:x], y: nextcoord[:y]})

      if @map["#{nextcoord[:x]},#{nextcoord[:y]}"][:terrain] == terrain
         return 1
      else
         rest_of_search = find_terrain_by_transform(nextcoord, transform, terrain, size)
         if rest_of_search == nil
            return nil
         else
            return 1+rest_of_search
         end
      end

   end


   # look at adjacent hexs until match condition met, returning the path taken to that point
   def self.breadth_search(startcoord, size, can_be_traversed, is_found, checked=Array.new)

      # add coord to the queue and then process the queue
      queue = Queue.new
      queue.push({
         :coord => startcoord,
         :path => Array.new
      })

      startnode = true

      while queue.length > 0 do

         # get coord to process
         step = queue.pop
         coord = step[:coord]
         path = step[:path]

         # check if coord is inside map and not excluded
         if MapUtils::mapcontains(size, {x: coord[:x], y: coord[:y]}) and
            !checked.include? "#{coord[:x]},#{coord[:y]}"

            # add to checked
            checked.push "#{coord[:x]},#{coord[:y]}"

            # check if this hex should be blocked
            if can_be_traversed.nil? or can_be_traversed.call(coord, path, startnode)

               startnode = false

               # check if this search complete and return path
               if is_found.call(coord, path)
                  return path.push(coord)
               else

                  # add all adjacents to the queue
                  transforms = self.adjacent_transforms
                  transforms.each { | transform |

                     # add to queue
                     nextcoord = MapUtils::transform_coord(coord, transform)
                     queue.push({
                        :coord => nextcoord,
                        :path => Array.new.replace(path).push(nextcoord)
                     })
                  }
               end # found

            end # dont traverse
         end # not in map or excluded
      end # more to process

      nil
   end

   # when we are searching for a path to a know coord then we can do better
   # with A* which estimates min distance and prioritises direct route
   def self.a_star_search()
   end

end

end