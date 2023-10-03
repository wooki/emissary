require 'json'
require 'optparse'
require_relative '../models/game_state'
require_relative '../models/area'
require_relative '../models/settlement'
require_relative '../models/trade_node'
require_relative '../models/area_link'
require_relative '../models/constants'

class NewGame

  attr_accessor :state

  # load map.json and create game state, save game state
  def initialize(gamefile, mapfile)

    # create an empty gamestate
    @state = Emissary::GameState.new

    # load the map and add to gamestate
    map = JSON.parse(File.read(mapfile), {:symbolize_names => true})

    # convert map HashMaps to objects
    @state.map = Hash.new
    map.each { | key, area |
      if @state.urban.include? area[:terrain]

        a = Emissary::Settlement.new
        a.x = area[:x]
        a.y = area[:y]
        a.terrain = area[:terrain]
        a.name = area[:name]
        a.population = area[:population]
        a.food = area[:food]
        a.goods = area[:goods]        

        a.shortcut = area[:shortcut]
        a.shortcut_help = area[:shortcut_help]
        a.owner = area[:owner]
        
        if area[:trade] 
          a.trade = Emissary::AreaLink.new
          a.trade.x = area[:trade][:x]
          a.trade.y = area[:trade][:y]
          a.trade.distance = area[:trade][:distance]
          a.trade.name = area[:trade][:name]
        end
        
        # lets have some starting gold
        a.store.gold = [Emissary::START_GOLD_MAX,
                        (Emissary::START_GOLD_PER_POPULATION * a.population).round(0).to_i].min

        if area[:neighbours]
          a.neighbours = area[:neighbours]
        end

        if area[:borders]
          a.borders = area[:borders]
        end

        if area[:trade] and !area[:trade][:is_node]
          a.trade = Emissary::AreaLink.new
          a.trade.x = area[:trade][:x]
          a.trade.y = area[:trade][:y]
          a.trade.distance = area[:trade][:distance]
          a.trade.name = area[:trade][:name]
        end

      else
        a = Emissary::Area.new
        a.x = area[:x]
        a.y = area[:y]
        a.terrain = area[:terrain]
        # a.name = area[:name] # should areas have names? maybe later
        a.population = area[:population]
        a.food = area[:food]
        a.goods = area[:goods]

        if area[:trade] 
          a.trade = Emissary::AreaLink.new
          a.trade.x = area[:trade][:x]
          a.trade.y = area[:trade][:y]
          a.trade.distance = area[:trade][:distance]
          a.trade.name = area[:trade][:name]
        end

        if area[:province]
          a.province = Emissary::AreaLink.new
          a.province.x = area[:province][:x]
          a.province.y = area[:province][:y]
          a.province.distance = area[:province][:distance]
          a.province.name = area[:province][:name]
        end

      end

      if area[:trade] and area[:trade][:is_node]
        a.trade_node = Emissary::TradeNode.new
        a.trade_node.name = area[:trade][:name]

        if area[:trade][:connected]
          area[:trade][:connected].each { | node_key, node |
            connection = Emissary::AreaLink.new
            connection.x = node[:x]
            connection.y = node[:y]
            connection.distance = node[:distance]
            connection.name = node[:name]
            a.trade_node.connected[node_key] = connection
          }
        end
      end

      @state.map[key] = a
    }

    # save the gamestate
    @state.save gamefile
  end

end

# parse command line options
options = Hash.new
OptionParser.new do | opts |
   opts.banner = "Usage: new_game.rb [options]"

   opts.on("-gGAME", "--gamefile=GAME", "File to read/write game to") do |n|
     options[:gamefile] = n
   end

   opts.on("-mFILE", "--map=FILE", "Map file to read") do |n|
     options[:mapfile] = n
   end
end.parse!

ng = NewGame.new options[:gamefile], options[:mapfile]

# bundle exec ruby new_game.rb -g game.yaml -m map.json