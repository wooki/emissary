require 'json'
require 'optparse'
require_relative '../models/game_state'
require_relative '../models/kingdom'

class AddKingdom
  attr_accessor :state

  # load game state, save game state
  def initialize(gamefile, player, kingdom, capital, flag)
    @state = Emissary::GameState.load(gamefile)

    # check we have a unique player, kingdom
    by_name = @state.kingdom_by_name kingdom
    if by_name
      puts 'Duplicate kingdom name'
      return
    end

    by_player = @state.kingdom_by_player player
    if by_player
      puts 'Duplicate player id'
      return
    end

    # flag must be five different digits
    unless last_three_different_digits? flag
      flag = generate_unique_digits_string
      puts "Flag was invalid, generating a random flag (#{flag})"
    end

    # check flag is sufficiently unique, allowed 2 to be the same
    @state.each_flag do |existing_flag|
      if compare_flags(flag, existing_flag) > 2
        puts "Flag (#{flag}) was too similar to an existing flag (#{existing_flag})"
        return
      end
    end

    # check existing data
    hex = @state.find_settlement capital

    # try and add the kingdom
    if hex

      by_capital = @state.kingdom_by_capital hex
      if by_capital
        puts 'Duplicate capital'
        return
      end

    else
      puts 'Capital not found, selecting random'
      urbans = @state.each_urban.select { |urban| !urban.owner }
      hex = urbans.sample
    end

    # add them
    k = Emissary::Kingdom.new
    k.name = kingdom
    k.player = player
    k.capital = hex.name
    k.flag = flag
    k.capital_coord = { x: hex.x, y: hex.y }
    @state.kingdoms[player] = k

    # set ownership
    hex.owner = player
    
    # add every hex in their region as explored
    @state.each_province_by_region(hex.trade) { | province |
      @state.each_area_in_province(province) { | area |
        k.explored.push area.coord_sym
      }
    }
      

    # add every adjacent province

    # save the gamestate
    @state.save gamefile
  end

  def last_three_different_digits?(input_string)
    # Check if the input string is exactly five characters long
    return false unless !input_string.nil? and input_string.length == 5

    # Check if all characters are digits
    return false unless input_string.match?(/\A\d{4}\z/)

    # check only last three
    digits = input_string[0, 3].chars.map(&:to_i)

    # also check for some bad contrast colours
    return false if [4,5,6,7].include?(digits[0]) && [4,5,6,7].include?(digits[1])    
    
    # Check if all digits are unique
    digits.uniq.length == 3
  end

  def generate_unique_digits_string
    # Create an array of digits 0 to 9
    all_digits = (0..9).to_a

    # Shuffle the array to randomize the order
    shuffled_digits = all_digits.shuffle

    # Take the first five digits from the shuffled array
    unique_digits = shuffled_digits[0, 3]
    unique_digits.unshift all_digits.sample
    unique_digits.unshift all_digits.sample

    # Convert the array to a string
    unique_digits.join
  end

  def compare_flags(string1, string2)
    # Check if the input strings are of the same length
    return 0 unless string1.length == string2.length
    return 0 unless string1.length == 5

    # Initialize a counter for matching digits in the same position
    count_same_position = 0.0

    # count some positions more or less than 1, so we get a score
    count_same_position += 0.6 if string1[0] == string2[0]
    count_same_position += 0.3 if string1[1] == string2[1]
    count_same_position += 1.4 if string1[2] == string2[2]
    count_same_position += 1.4 if string1[3] == string2[3]
    count_same_position += 0.3 if string1[4] == string2[4]

    count_same_position
  end
end

# parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: add_kingdom.rb [options]'

  opts.on('-gGAME', '--gamefile=GAME', 'File to read/write game to') do |n|
    options[:gamefile] = n
  end

  opts.on('-pPLAYER', '--player=PLAYER', 'Player id for the kingdom (anything unique)') do |n|
    options[:player] = n.to_sym
  end

  opts.on('-kKINGDOM', '--kingdom=KINGDOM', 'Kingdom name') do |n|
    options[:kingdom] = n
  end

  opts.on('-cCAPITAL', '--capital=CAPITAL', 'Capital city by short name') do |n|
    options[:capital] = n.to_sym
  end

  opts.on('--fFLAG', '--flag=FLAG', 'Five digit string representing flag') do |n|
    options[:flag] = n
  end
end.parse!

ng = AddKingdom.new options[:gamefile], options[:player], options[:kingdom], options[:capital], options[:flag]

# bundle exec ruby add_kingdom.rb -g game.yaml -p jim -c XXX -k "The Jimpire" -f "00000"
