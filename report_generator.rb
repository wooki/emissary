module Emissary

class ReportGenerator

  # create a report for specific user
  def run(game, player)

    # create a new gamestate for the turn data
    turn = Emissary::GameState.new

    # add the kingdoms (only ones met?  or all?)
    turn.kingdoms = game.kingdoms

    # add the players kingdom separately
    game.kingdoms.each { | kingdom |
      turn.my_kingdom = kingdom if kingdom.belongs_to == user_id
    }

    # iterate the areas this player owns and add areas plus adjacent
    # game.areas(user_id) { | key, area |

    #   # add this area
    #   turn.map[key] = area

    #   # add adjacent
    #   adjacent = area.adjacent(1, game.areas, game.map_size)
    #   adjacent.each { | adj |
    #     turn.map["#{adj.x},#{adj.y}"] = adj
    #   }

    #   false # return false to stop iterator from building return hash
    # }

    # iterate units and add those areas along with areas within vision
    # of the units



  end


end

end

