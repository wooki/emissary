module Emissary

    require "json"
  
    class OrderParser
  
      attr_accessor  :factionId,
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
      def OrderParser.ParseFolder(folder, gameState)
  
        # ready a return array
        parsers = Array.new
  
        # iterate factions
        gameState.each_player { | player |
  
          # work out the filename
          filename = folder + player + ".json"
          next if not File.exist?(filename)
  
          # create a parser for that factions file
          yield OrderParser.new(filename, player, gameState)
  
        }
  
        # return the array of parsers
        return parsers
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
  
        rescue
            @gameState.OrderError(@player, "No order file found")
            return
        end
  
        # all the sub elements are orders
        root.each_element { | order | begin
  
          # get the order name
          orderName = order.name
  
          # iterate children and build a parameter hash
          parameters = Array.new
          order.each_element { | parameter | begin
            concatText = ''
            parameter.texts.each { | text | concatText += text.value }
            parameters.push([parameter.name, concatText])
          end }
  
          # try and create the rule
          rf = RuleFactory.new
          r = rf.CreateRule(orderName, parameters, @factionId, @gameState)
  
          # order error if a systemrule!
          if r == nil
            puts "rule not created: #{orderName}"
          elsif r.systemrule
            @gameState.OrderError(@factionId, "Cannot issue system rule (#{orderName})")
          else
            # return a rule
            yield r if r
          end
  
        end }
  
  
      end
  
    end
  
  end