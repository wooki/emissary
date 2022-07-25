require 'json'
require 'optparse'
require_relative '../game_state'
require_relative '../turn'

class Turn

  attr_accessor :state

  # load game state and run turn
  def initialize(gamefile, ordersdir, seed)

    t = Emissary::Turn.new(gamefile, ordersdir, seed)

  end

end

# parse command line options
options = Hash.new
OptionParser.new do | opts |
   opts.banner = "Usage: turn.rb [options]"

   opts.on("-gGAME", "--gamefile=GAME", "File to read/write game to") do |n|
     options[:gamefile] = n
   end

   opts.on("-oORDERSDIR", "--orders=ORDERSDIR", "folder from which to read orders") do |n|
    options[:ordersdir] = n
  end

  opts.on("-sSEED", "--seed=SEED", "random seed for repeatable order run") do |n|
    options[:seed] = n.to_i
  end

end.parse!

ng = Turn.new options[:gamefile], options[:ordersdir], options[:seed]

# bundle exec ruby turn.rb -g game.yaml -o ../orders/ -s 123456
