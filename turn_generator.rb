module Wraithdale
  
class TurnGenerator
  
  # create a turn for specific user
  def run(game_id, user_id)
    
    # create a new gamestate for the turn data
    turn = Wraithdale::GameState.new
    
    # load the game
    game = Game::find(game_id)
    
    # add the kingdoms (only ones met?  or all?)
    turn.kingdoms = game.kingdoms
    
    # add the players kingdom separately
    game.kingdoms.each { | kingdom |
      turn.my_kingdom = kingdom if kingdom.belongs_to == user_id
    }
    
    # iterate the areas this player owns and add areas plus adjacent
    game.areas(user_id) { | key, area |
      
      # add this area
      turn.map[key] = area
      
      # add adjacent
      adjacent = area.adjacent(1, game.areas, game.map_size)
      adjacent.each { | adj |
        turn.map["#{adj.x},#{adj.y}"] = adj
      }
      
      false # return false to stop iterator from building return hash
    }
    
    # iterate units and add those areas along with areas within vision
    # of the units
    
    t = Turn.new
    t.game_id = game_id
    t.user_id = user_id
    t.turn_no = game.turn_no
    t.set_data turn
    t.save!
    
  end
  #########
  #handle_asynchronously :run

end
  
end

