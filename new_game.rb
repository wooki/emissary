module Emissary

require 'json'
require 'optparse'
require_relative 'game_state'

class NewGame

  attr_accessor :state

  # load map.json and create game state, save game state
  def initialize(gamefile, mapfile)

    # create an empty gamestate
    @state = Emissary::GameState.new

    # load the map and add to gamestate
    @state.map = JSON.parse(File.read(mapfile))

    # save the gamestate
    @state.save gamefile
  end

end

end

# parse command line options
options = Hash.new
OptionParser.new do | opts |
   opts.banner = "Usage: emissary.rb [options]"

   opts.on("-gGAME", "--gamefile=GAME", "File to read/write game to") do |n|
     options[:gamefile] = n
   end

   opts.on("-mFILE", "--map=FILE", "Map file to read") do |n|
     options[:mapfile] = n
   end
end.parse!

ng = Emissary::NewGame.new options[:gamefile], options[:mapfile]
