module Emissary
  require 'json'
  require 'yaml'
  require 'random/formatter'
  require_relative './map_helpers'
  require_relative './area'
  require_relative './settlement'
  require_relative './trade_node'
  require_relative './area_link'
  require_relative './store'
  require_relative './kingdom'
  require_relative './constants'
  require_relative './message'
  require_relative './agent'  

  class GameState
    attr_accessor :kingdoms, :map, :settlements, :turn, :messages, :errors

    def initialize
      super()

      # keyed by user id
      @kingdoms = {}

      # keyed by "x,y" (areas contain units)
      @map = {}

      @turn = 0

      @messages = {}
      @errors = {}

      @rnd = Random.new
    end

    def self.load(gamefile)
      # load the gamestate
      # data = File.read(gamefile)
      # self.from_json(data)
      state = YAML.unsafe_load_file(gamefile)
      state.load_settlements
      state
    end

    def random_id
      prng = Random.new 1 # always use the same number sequence
      @rnd.alphanumeric(16)
    end

    def getCapital(player)
      kingdom = self.kingdom_by_player(player)
      getHex(kingdom.capital_coord[:x], kingdom.capital_coord[:y])
    end    

    def getHex(x, y)
      @map["#{x},#{y}".to_sym]
    end

    def getHexFromCoord(coord)
      @map["#{coord[:x]},#{coord[:y]}".to_sym]
    end

    def getCoord(coord)
      @map["#{coord}".to_sym]
    end

    # log information to hex, for filter and reporting to players
    # "PRODUCTION", @area, "Food and Goods sent to #{@settlement[:name]}", {food: food, goods: goods}
    def info(type, area, message, data = {}, player = nil)
      
      # info level determined by looking up type
      level = INFO_LEVELS[type.to_sym]

      return unless area

      area.info = [] unless area.info

      area.info.push({
                       level:,
                       type:,
                       message:,
                       data:,
                       player:
                     })
    end

    def order_error(player, message)
      @errors[player] = [] unless @errors.include?(player)
      @errors[player].push Message.new(message, 'host')
    end

    def player_message(player, message, from)
      @messages[player] = [] unless @messages.include?(player)
      @messages[player].push Message.new(message, from)
    end

    # work out the largest x/y dimension
    def size
      largest = 0
      @map.each do |_key, hex|
        largest = hex.x if hex.x > largest
        largest = hex.y if hex.y > largest
      end
      largest
    end

    # shortcut to settlements in the map hash based on unique
    # short strings
    def load_settlements
      @settlements = {}

      # iterate settlements and assign shortcuts to each
      @map.each do |key, hex|
        next unless %w[town city].include? hex.terrain

        if hex.shortcut
          code = hex.shortcut
          shortcut_help = hex.shortcut_help

        elsif hex.name.include? ' '
          parts = hex.name.downcase.split
          code = parts.collect { |part| part[0, 1] }.join
          shortcut_help = parts.collect { |part| part[0, 1].upcase + part[1, 99].downcase }.join(' ')

          if @settlements.include? code.to_sym
            code = parts[0][0, 1] + parts[1][0, 2]
            shortcut_help = parts[0][0,
                                     1].upcase + parts[0][1,
                                                          99].downcase + ' ' + parts[1][0,
                                                                                        2].upcase + parts[1][2,
                                                                                                             99].downcase
          end

          if @settlements.include? code.to_sym
            code = parts[0][0, 2] + parts[1][0, 1]
            shortcut_help = parts[0][0,
                                     2].upcase + parts[0][2,
                                                          99].downcase + ' ' + parts[1][0,
                                                                                        1].upcase + parts[1][1,
                                                                                                             99].downcase
          end

          if @settlements.include? code.to_sym
            code = parts.collect { |part| part[0, 2] }.join
            shortcut_help = parts.collect { |part| part[0, 2].upcase + part[2, 99].downcase }.join(' ')
          end

          if @settlements.include? code.to_sym
            code = parts[0][0, 2] + parts[1][0, 3]
            shortcut_help = parts[0][0,
                                     2].upcase + parts[0][2,
                                                          99].downcase + ' ' + parts[1][0,
                                                                                        3].upcase + parts[1][3,
                                                                                                             99].downcase
          end
        else

          code = hex.name[0, 3].downcase
          shortcut_help = hex.name[0, 3].upcase + hex.name[3, 99].downcase

          if @settlements.include? code.to_sym
            code = hex.name[0, 4].downcase
            shortcut_help = hex.name[0, 4].upcase + hex.name[4, 99].downcase
          end

          if @settlements.include? code.to_sym
            code = hex.name[0, 5].downcase
            shortcut_help = hex.name[0, 5].upcase + hex.name[5, 99].downcase
          end

          if @settlements.include? code.to_sym
            code = hex.name.downcase
            shortcut_help = hex.name.upcase
          end
        end

        hex.shortcut = code.to_sym
        hex.shortcut_help = shortcut_help.to_sym
        @settlements[code.to_sym] = key
      end
    end

    # find a settlement with a short version of the name
    def find_settlement(name_fragment)
      coord = @settlements[name_fragment]
      return unless coord

      @map[coord]
    end

    def each_flag
      flags = []
      @kingdoms.each do |_key, kingdom|
        flags.push kingdom.flag if !block_given? or yield kingdom.flag
      end
      return nil if flags.length == 0

      flags
    end

    def each_player
      players = []
      @kingdoms.each do |_key, kingdom|
        players.push players if !block_given? or yield kingdom.player, kingdom
      end

      return nil if players.length == 0

      players
    end

    def kingdom_by_name(name)
      @kingdoms.values.find { |kingdom| kingdom.name == name }
    end

    def kingdom_by_player(name)
      @kingdoms[name]
    end

    def kingdom_by_capital(coord)
      @kingdoms.values.find { |kingdom| kingdom.x == coord[:x] and kingdom.y == coord[:y] }
    end

    def rural
      %w[lowland mountain forest desert]
    end

    def urban
      %w[town city]
    end

    # get all of the specified terrain from the map
    # and return array - if block then only include
    # items where block returns true
    def each_area(terrain = nil)
      matched = []
      terrain = [terrain] if !terrain.nil? and !terrain.is_a? Array

      @map.each do |_key, value|
        next unless terrain.nil? or terrain.include? value.terrain

        matched.push value if !block_given? or yield value
      end
      matched
    end

    def areas(coords = nil)
      return @map if coords.nil?

      @map.select { |_key, area| coords.include? area.coord }
    end

    def each_rural(&block)
      each_area rural, &block
    end

    def each_urban(&block)
      each_area urban, &block
    end

    def each_province_by_region(region, &block)
      matched = []
      self.each_urban do |urban|
        if urban.trade.coord_sym == region.coord_sym
          matched.push urban if !block_given? or yield urban
        end
      end
      matched
    end

    def each_area_in_province(province, &block)
      matched = []
      self.each_area do |area|
        if area.coord_sym == province.coord_sym or 
          (!area.province.nil? and area.province.coord_sym == province.coord_sym)
          matched.push area if !block_given? or yield area
        end
      end
      matched
    end

    def each_trade_node
      matched = []

      @map.each do |_key, value|
        next unless value.trade_node and value.trade_node.is_node

        matched.push value if !block_given? or yield value
      end
      matched
    end
    alias each_region each_trade_node    

    def each_agent
      matched = []

      @map.each do |_key, area|
        
        area.agents.each do | _agent_key, agent |
          matched.push agent if !block_given? or yield _agent_key, agent, area
        end

      end
      matched
    end

    def agent_report(start, max_distance)
      MapHelpers.get_hexes_in_range(self, start.coord, size, max_distance, exclude_ocean=true, terrain_weights=AGENT_REPORT_TERRAIN_WEIGHTS)
    end

    def find_agent(agent_id)
      each_agent do |agent_key, agent, area|
        if agent_id == agent_key
          yield agent, area
        end
      end      
    end

    def retire(agent)

      # for now remove agent but in future maybe keep them
      # and allow others to hire them
      find_agent(agent.id) do | agent, area |
        area.remove_agent(agent)
      end
      
    end

    ##################################
    # get the kingom object for specified user
    ##################################
    def kingdom_for_user(user_id)
      @kingdoms.each do |_key, kingdom|
        return kingdom if kingdom.player == user_id
      end
      nil
    end

    ##################################
    # check the kingdom/capital names unique
    ##################################
    def kingdom_names_unique(name, capital)
      @kingdoms.each do |_key, kingdom|
        return false if kingdom.name.downcase.gsub!(/\s+/, '') == name.downcase.gsub!(/\s+/, '') or
                        kingdom.capital.downcase.gsub!(/\s+/, '') == capital.downcase.gsub!(/\s+/, '')
      end
      true
    end

    ##################################
    # clears old data and increments
    # turn
    ##################################
    def new_turn(randomseed)
      # clear old data
      puts 'clearing old data'
      @messages = {}
      @errors = {}

      # reset information
      each_area do |area|
        area.new_turn
      end

      # reset ships
      # self.each_ship { | ship |
      # 	ship.new_turn
      # }

      # increment turn no
      @turn = @turn.next
      puts "moving to turn #{@turn}"

      # ensure we can repeat rand calls by logging
      # and allowing the reuse of a seed
      if [nil, ''].include?(randomseed)
        randomseed = rand(1_000_000)
        puts "random seed generated: #{randomseed}"
        @randomseed = randomseed
      else
        puts "random seed set to: #{randomseed}"
        @randomseed = randomseed
      end
      srand(@randomseed)
    end

    ##################################
    # converts the map to an array suitible for rendering in rails as json
    ##################################
    def map_array
      maparray = []
      @map.each do |_key, area|
        maparray.push area
      end
      maparray
    end

    def save(gamefile)
      # save the gamestate
      # File.open(gamefile, 'w') do | file |
      #   file.print JSON.pretty_generate(self)
      # end

      File.open(gamefile, 'w') do |file|
        file.print YAML.dump(self)
      end
    end
  end
end
