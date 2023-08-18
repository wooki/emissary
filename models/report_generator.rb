module Emissary

class ReportGenerator

  # create a report for specific user
  def run(game, player)

    # create a new gamestate for the turn data
    turn = Emissary::GameState.new

    # add the kingdoms (only ones met? or all?)
    turn.kingdoms = game.kingdoms

    # add the players kingdom separately
    turn.my_kingdom = game.kingdom_by_player player
    puts "my_kingdom: #{turn.my_kingdom.inspect}"    
    
    # check which trade node the players capital is in
    capital = game.map[turn.my_kingdom.capital_coord_sym]
    puts "capital: #{capital.inspect}"

    # build array of urban areas from which all map info is discovered
    known_urbans = Array.new
    known_urbans.push capital.coord_sym
    
    # iterate the urban areas adding if owned, or in the same trade node    
    game.each_urban { | urban |

      if urban.owner == player or 
         urban.trade.coord_sym == capital.trade.coord_sym        

        known_urbans.push urban.coord_sym
      end                

      false
    }

    # add all areas that are closest to the urbans this player knows about
    game.each_area { | area |
    
      if known_urbans.include? area.coord_sym or
        (area.closest_settlement and known_urbans.include? area.closest_settlement.coord_sym)

        turn.map[area.coord_sym] = area

        # add adjacent
        adjacent_coords = MapUtils::adjacent(area.coord, game.size)
        adjacent = game.areas adjacent_coords
        adjacent.each { | adj |
          turn.map[adj.coord_sym] = adj
        }
      end

      false # return false to stop iterator from building return hash
    }
    
    # save the player turn
    


  end


end

end

