require 'json'
require 'optparse'
require_relative '../game_state'

class AddKingdom

  attr_accessor :state

  # load game state, save game state
  def initialize(gamefile, player, kingdom, capital)

    @state = Emissary::GameState.load(gamefile)

    # check we have a unique player, kingdom
    by_name = @state.kingdom_by_name kingdom
    if by_name
      puts "Duplicate kingdom name"
      return
    end

    by_player = @state.kingdom_by_player player
    if by_player
      puts "Duplicate player id"
      return
    end


    # check existing data
    hex = @state.find_settlement capital

    # try and add the kingdom
    if hex

      by_capital = @state.kingdom_by_capital hex
      if by_capital
        puts "Duplicate capital"
        return
      end


    else
      puts "Capital not found"
      return
    end

    # add them
    @state.kingdoms[player] = {
      :name => kingdom,
      :player => player,
      :x => hex.x,
      :y => hex.y,
      :capital => hex.name
    }

    # set ownership
    hex.owner = player

    # save the gamestate
    @state.save gamefile
  end

end


# parse command line options
options = Hash.new
OptionParser.new do | opts |
   opts.banner = "Usage: add_kingdom.rb [options]"

  opts.on("-gGAME", "--gamefile=GAME", "File to read/write game to") do |n|
     options[:gamefile] = n
  end

  opts.on("-pPLAYER", "--player=PLAYER", "Player id for the kingdom (anything unique)") do |n|
    options[:player] = n.to_sym
  end

  opts.on("-kKINGDOM", "--kingdom=KINGDOM", "Kingdom name") do |n|
    options[:kingdom] = n
  end

  opts.on("-cCAPITAL", "--capital=CAPITAL", "Capital city by short name") do |n|
    options[:capital] = n.to_sym
  end
end.parse!

ng = AddKingdom.new options[:gamefile], options[:player], options[:kingdom], options[:capital]


# bundle exec ruby add_kingdom.rb -g game.yaml -p jim -c val -k "The Jimpire"