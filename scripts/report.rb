require 'json'
require 'optparse'
require_relative '../models/game_state'
require_relative '../models/report_generator'

class Reporter
  attr_accessor :state

  # load game state and run turn
  def initialize(gamefile, reportsdir, player)
    
    # get the game
    @state = Emissary::GameState.load(gamefile)

    # produce report
    reports = Emissary::ReportGenerator.new reportsdir
    @state.each_player do |p, _kingdom|
      reports.run @state, p if player.nil? or player.empty? or player == p.to_s
    end
  end
end

# parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: turn.rb [options]'

  opts.on('-gGAME', '--gamefile=GAME', 'File to read/write game to') do |n|
    options[:gamefile] = n
  end

  opts.on('-rREPORTSDIR', '--reports=REPORTSDIR', 'folder to write report files') do |n|
    options[:reportsdir] = n
  end

  opts.on('-pPLAYER', '--player=PLAYER', 'player to create report for') do |n|
    options[:player] = n
  end
  
end.parse!

ng = Reporter.new options[:gamefile], options[:reportsdir], options[:player]

# bundle exec ruby report.rb -g game.yaml -r ../reports/ -p stu
