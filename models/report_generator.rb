require 'json'
require_relative '../models/constants'
require_relative '../models/report'

module Emissary
  class ReportGenerator
    def initialize(reportsdir)
      @reportsdir = reportsdir      
    end

    def add_area(area, level, report, player, game)
      return unless !@levels.has_key?(area.coord_sym) or @levels[area.coord_sym] < level
      
      report.map[area.coord_sym] = area.report(level, player, game)
      @levels[area.coord_sym] = level
    end

    # create a report for specific user
    def run(game, player)

      # reset levels
      @levels = {}

      # create a new gamestate for the report data
      report = Emissary::Report.new
      report.turn = game.turn

      # add the kingdoms (only ones met? or all?)
      report.kingdoms = game.kingdoms

      # add the players kingdom separately
      report.my_kingdom = game.kingdom_by_player player

      # add messages and errors
      report.messages = game.messages[player]
      report.errors = game.errors[player]

      # check which trade node the players capital is in
      capital = game.map[report.my_kingdom.capital_coord_sym]

      # build array of urban areas from which all map info is discovered
      known_urbans = {}
      known_urbans[capital.coord_sym] = INFO_LEVELS[:PUBLIC]

      known_trade_nodes = []

      # iterate the urban areas adding if owned, or in the same trade node,
      # adjacent to capital or you have an agent
      game.each_urban do |urban|
        if urban.owner == player

          known_urbans[urban.coord_sym] = INFO_LEVELS[:PUBLIC]
          known_trade_nodes.push urban.trade.coord_sym if urban.trade

        elsif urban.trade.coord_sym == capital.trade.coord_sym

          known_urbans[urban.coord_sym] = INFO_LEVELS[:PUBLIC]

        elsif capital.neighbours.any? { |coord| urban.x == coord[:x] and urban.y == coord[:y] }

          known_urbans[urban.coord_sym] = INFO_LEVELS[:PUBLIC]

        end

        false
      end
      known_trade_nodes.uniq!

      # add all areas that are in provinces this player knows about
      game.each_area do |area|
        if known_urbans.has_key? area.coord_sym

          add_area(area, known_urbans[area.coord_sym], report, player, game)

        elsif area.province and known_urbans.has_key? area.province.coord_sym

          add_area(area, known_urbans[area.province.coord_sym], report, player, game)              

        end

        false # return false to stop iterator from building return hash
      end

      # TODO: RETHINK ALL OF THE ABOVE, DON'T REVEAL AS MUCH OF THE MAP
      # Make whole trade node level 0 (known) which can be drawn but is not
      # proving anything except terrain.      
      # then everything else is added based on agents and owned areas
      
      # agents report on area and surroundings
      agents = game.each_agent do | agent_key, agent, area |
        if agent.owner == player          
          add_area(area, agent.depth, report, player, game)

          # TODO: also add entire proivince at KNOWN level IF the area is a settlement

          # TODO: also get all areas within range, with decreasing depth
          

        end
      end

      # KNOWN AREAS MUST BE TRACKED (this is how explored will work, so they are)
      # always reported on even in later turns

      # TODO: add areas (not provinces) that your scouts can reach

      # TODO: add EXPLORED trade nodes only ocean and coastline
      

      # save the player turn
      puts "saving to #{@reportsdir}report.#{player}.#{report.turn}.json"
      File.open("#{@reportsdir}report.#{player}.#{report.turn}.json", 'w') do |file|
        # file.print map.to_json
        file.print JSON.pretty_generate(report)
      end
    end
  end
end
