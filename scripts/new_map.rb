require 'json'
require 'optparse'
require_relative '../models/game_state'
require_relative '../models/map_utils'
require_relative '../models/map_generator'

# parse command line options
options = {
   size: 100,
   hexsize: 18
}
OptionParser.new do | opts |
   opts.banner = "Usage: new_map.rb [options]"

   # input json file

   opts.on("-fFILE", "--fileout=FILE", "File to write map to") do |n|
     options[:file] = n
   end

   opts.on("-sSEED", "--seed=SEED", "Seed for random generation") do |n|
     options[:seed] = n.to_i
   end

   opts.on("-FFORMAT", "--format=FORMAT", "SVG or JSON") do |n|
     options[:format] = n
   end

   opts.on("-SSIZE", "--size=SIZE", "Width and height of the map") do |n|
     options[:size] = n.to_i
   end

   opts.on("-hHEXSIZE", "--hesize=HEXSIZE", "Size to draw each hex in the Svg") do |n|
     options[:hexsize] = n.to_i
   end
end.parse!

seeded = nil
seeded = options[:seed]
mg = Emissary::MapGenerator.new seeded

map = mg.generate options[:size]

if options[:file] and options[:format] == "json"
   $stdout.print "#{mg.seed}"
   File.open(options[:file], 'w') do | file |
      # file.print map.to_json
      file.print JSON.pretty_generate(map)
   end
elsif options[:format] == "json"

   # print map.to_json
   print JSON.pretty_generate(map)

elsif options[:file]
   File.open(options[:file], 'w') do | file |
      mg.to_svg options[:hexsize], file
   end
else
   mg.to_svg options[:hexsize], $stdout
end

# pipe seed from json gen to svg so we get same map twice
# bundle exec ruby new_map.rb -f map.json -F json -S 100 -h 6 | xargs -I % sh -c 'bundle exec ruby new_map.rb -f map.svg -S 100 -h 6 --seed=%'

# inland sea
#bundle exec ruby new_map.rb -f map.svg -S 100 -h 6 --seed=127381668545450955056731370432757770900
#<!-- SEED: "127381668545450955056731370432757770900" -->