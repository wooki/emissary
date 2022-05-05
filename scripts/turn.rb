require_relative '../game_state'
require_relative '../turn'

codebase = ARGV[0]
separator = ARGV[1]
gamefile = ARGV[2]
ordersdir = ARGV[3]
simulate = ARGV[4]
randomseed = ARGV[5]

t = Emissary::Turn.new(gamefile, ordersdir, simulate, randomseed)
