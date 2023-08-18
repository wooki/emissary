require 'json'
require 'optparse'
require_relative '../models/game_state'
require_relative '../models/turn'

class Turn

  attr_accessor :state

  # load game state and run turn
  def initialize(gamefile, ordersdir, reportsdir, seed)

    t = Emissary::Turn.new(gamefile, ordersdir, reportsdir, seed)

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

  opts.on("-rREPORTSDIR", "--reports=REPORTSDIR", "folder to write report files") do |n|
    options[:reportsdir] = n
  end

  opts.on("-sSEED", "--seed=SEED", "random seed for repeatable order run") do |n|
    options[:seed] = n.to_i
  end

end.parse!

ng = Turn.new options[:gamefile], options[:ordersdir], options[:reportsdir], options[:seed]

# bundle exec ruby turn.rb -g game.yaml -o ../orders/ -r ../reports/ -s 123456
