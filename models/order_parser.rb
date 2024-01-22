module Emissary
  require 'json'

  class OrderParser
    attr_accessor :factionId,
                  :filename

    ##################################
    #
    ###################################
    def initialize(filename, player, gameState)
      super()
      @filename = filename
      @player = player
      @gameState = gameState
    end

    ##################################
    # static method to iterate order
    # parsers for every faction
    ##################################
    def self.ParseFolder(folder, gameState)
      # ready a return array
      parsers = []

      # iterate factions
      gameState.each_player do |player|
        # work out the filename
        filename = folder + player + '.json'
        next unless File.exist?(filename)

        # create a parser for that factions file
        yield OrderParser.new(filename, player, gameState)
      end

      # return the array of parsers
      parsers
    end

    ##################################
    # iterate orders in the file,
    # creating rules for each one
    ##################################
    def each
      begin
        # load json file
        file = File.new(@filename)
        data = JSON.parse(file)
        file.close
      rescue StandardError
        @gameState.OrderError(@player, 'No order file found')
        return
      end

      # all the sub elements are orders
      root.each_element do |order|
        # get the order name
        orderName = order.name

        # iterate children and build a parameter hash
        parameters = []
        order.each_element do |parameter|
          concatText = ''
          parameter.texts.each { |text| concatText += text.value }
          parameters.push([parameter.name, concatText])
        end

        # try and create the rule
        rf = RuleFactory.new
        r = rf.CreateRule(orderName, parameters, @factionId, @gameState)

        # order error if a systemrule!
        if r.nil?
          puts "rule not created: #{orderName}"
        elsif r.systemrule
          @gameState.OrderError(@factionId, "Cannot issue system rule (#{orderName})")
        elsif r
          yield r
        end
        # return a rule
      end
    end
  end
end
