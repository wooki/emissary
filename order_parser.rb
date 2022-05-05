module Emissary

  require "rexml/document"

  #
  class OrderParser

    attr_accessor  :factionId,
                  :filename

    ##################################
    #
    ###################################
    def initialize(filename, factionId, gameState)
      super()
      @filename = filename
      @factionId = factionId
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
      gameState.each_faction { | faction |

        # work out the filename
        filename = folder + "orders" + faction.gameId.to_s + ".xml"

      # create a parser for that factions file
        yield OrderParser.new(filename, faction.gameId, gameState)

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

      # load xml file
      file = File.new(@filename)
      doc = REXML::Document.new(file)
      file.close
      root = doc.root

      rescue
          @gameState.OrderError(@factionId, "No order file found")
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