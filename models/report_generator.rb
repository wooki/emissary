require 'json'
require_relative '../models/constants'

module Emissary

class ReportGenerator
  
  def initialize(reportsdir) 
    @reportsdir = reportsdir
    @levels = Hash.new
  end

  def add_area(area, level, turn)
    if !@levels.has_key?(area.coord_sym) or @levels[area.coord_sym] < level
      turn.map[area.coord_sym] = area.report(level)
      @levels[area.coord_sym] = level
    end

  end

  # create a report for specific user
  def run(game, player)

    # create a new gamestate for the turn data
    turn = Emissary::GameState.new
    turn.turn = game.turn

    # add the kingdoms (only ones met? or all?)
    turn.kingdoms = game.kingdoms

    # add the players kingdom separately
    turn.my_kingdom = game.kingdom_by_player player

    # check which trade node the players capital is in
    capital = game.map[turn.my_kingdom.capital_coord_sym]
    
    # build array of urban areas from which all map info is discovered
    known_urbans = Hash.new
    known_urbans[capital.coord_sym] = INFO_LEVELS[:OWNED]
    
    # iterate the urban areas adding if owned, or in the same trade node    
    game.each_urban { | urban |

      if urban.owner == player 

        known_urbans[urban.coord_sym] = INFO_LEVELS[:OWNED]

      elsif urban.trade.coord_sym == capital.trade.coord_sym        

        known_urbans[urban.coord_sym] = INFO_LEVELS[:PUBLIC]
        
      end                

      false
    }    

    # add all areas that are closest to the urbans this player knows about
    game.each_area { | area |
    
      if known_urbans.has_key? area.coord_sym
        
        add_area(area, known_urbans[area.coord_sym], turn)

      elsif area.closest_settlement and known_urbans.has_key? area.closest_settlement.coord_sym

        add_area(area, known_urbans[area.closest_settlement.coord_sym], turn)        

        # # add adjacent
        # adjacent_coords = MapUtils::adjacent(area.coord, game.size)
        # adjacent = game.areas adjacent_coords
        # adjacent.each { | adj |
        #   turn.map[adj.coord_sym] = adj.report(99)
        # }
      end

      false # return false to stop iterator from building return hash
    }
    
    # save the player turn
    puts "saving to #{@reportsdir}"
    File.open("#{@reportsdir}report.#{player}.#{turn.turn}.json", 'w') do | file |
      # file.print map.to_json
      file.print JSON.pretty_generate(turn)
   end

  end


end

end

