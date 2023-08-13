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
    
    # iterate the urban areas adding if owned, 
    # and adding all areas that are "closest"
    game.each_urban { | key, urban |

      # if player owns this area then add all areas that are closest


    #   # add this area
    #   turn.map[key] = area

    #   # add adjacent
    #   adjacent = area.adjacent(1, game.areas, game.map_size)
    #   adjacent.each { | adj |
    #     turn.map["#{adj.x},#{adj.y}"] = adj
    #   }

      false # return false to stop iterator from building return hash
    }
    

  end


end

end

