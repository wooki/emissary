require_relative "../rulesengine/rule_factory.rb"
require_relative "../rulesengine/rule.rb"

module Emissary
  require 'json'

  class OrderParser
    attr_accessor :player,
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
        filename = "#{folder}turn.#{player}.#{(gameState.turn-1)}.json"
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
        data = JSON.load(file)
        file.close
      rescue StandardError => e        
        @gameState.order_error(@player, 'Error loading order file')
        return
      end

      # all the sub elements are orders
      data.each do |order|
        
        # get the order name
        orderName = order["order"]

        # iterate children and build a parameter hash
        parameters = []
        order.each do | parameter, value |
          parameters.push([parameter, value]) if parameter != "order"
        end

        # try and create the rule
        rf = RuleFactory.new
        r = rf.CreateRule(orderName, parameters, @player, @gameState)

        # order error if a systemrule!
        if r.nil?
          puts "rule not created: #{orderName}"
        elsif r.systemrule
          @gameState.order_error(@player, "Cannot issue system rule (#{orderName})")
        elsif r
          yield r
        end
        # return a rule
      end
    end
  end
end
