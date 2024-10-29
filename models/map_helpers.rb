require 'emissary-maps'

module Emissary

    class MapHelpers
        def self.get_hexes_in_range(state, startcoord, size, max_distance, exclude_ocean, terrain_weights)

            hexes = Hash.new
            checked = Array.new

            MapUtils::breadth_search(startcoord, size,
            # can_be_traversed
            Proc.new { |coord, path, startnode|
                # Get terrain of current hex
                nexthex = state.getHexFromCoord(coord)
                terrain = nexthex.terrain
                
                # Skip if it's ocean and we're excluding ocean
                return false if exclude_ocean && terrain == :ocean
                
                # Calculate total path cost including current hex
                path_cost = path.reduce(0) { |sum, hex| 
                    sum + (terrain_weights[state.getHexFromCoord(hex).terrain] || 1)
                }
                current_cost = terrain_weights[terrain] || 1
                
                # Allow traversal if within max_distance
                (path_cost + current_cost) <= max_distance                
            },
            # is_found
            Proc.new { |coord, path|
                # Get terrain of current hex
                nexthex = state.getHexFromCoord(coord)
                terrain = nexthex.terrain
                
                # Add valid hex to results if not already included
                hex_key = "#{coord[:x]},#{coord[:y]}"
                if !hexes.has_key?(hex_key)

                    # Calculate total path cost excluding current hex
                    path_cost = path.reduce(0) { |sum, hex| 
                        sum + (terrain_weights[state.getHexFromCoord(hex).terrain] || 1)
                    }
                    
                    hexes.store(hex_key, {
                        x: coord[:x], 
                        y: coord[:y], 
                        score: (path_cost + current_cost)
                    })
                end
                # Never "found" - continue searching until max_distance reached
                false
            },
            checked
            )

            hexes.values     
        end

    end
end