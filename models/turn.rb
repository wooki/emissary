require_relative '../rulesengine/rule_queue'
require_relative '../rules/production'
require_relative '../rules/import'
require_relative '../rules/export'
require_relative '../rules/industry'
require_relative '../rules/upkeep'
require_relative '../rules/trade_prices'
require_relative './report_generator'
require_relative './map_utils'

module Emissary

  # runs a turn
  class Turn

  def initialize(gamefile, ordersdir, reportsdir, seed)

      # get the game
      @state = Emissary::GameState.load(gamefile)

      # clear old data
      @state.new_turn(seed)

      # build a rule queue from orders
      puts "building rule queue"
      queue = RuleQueue.new

      # parse player orders
      # Emissary::OrderParser.ParseFolder(ordersdir, game) { | parser |
      #   puts "  parsing player #{game.faction_name(parser.player)} (#{parser.player})"
      #   parser.each { | rule |
      #     queue.AddRule(rule)
      #   }
      # }

      # add system orders for areas, settlements etc.
      puts "adding system rules"

      # system rules generate notifications for players. Depending on how good (or many)
      # peeple they have on internal affairs they get top x, based on each notifications magnitude.
      # Their spymaster plus spies report based on where they are?

      # Production
      @state.each_rural.each { | area |
        queue.AddRule(Production.new(area))

        if area.trade_node and area.trade_node.is_node
          queue.AddRule(TradePrices.new(area))
        end
      }


      # Import, Export, Industry, Upkeep
      @state.each_urban.each { | area |
        queue.AddRule(Import.new(area))
        queue.AddRule(Export.new(area))
        queue.AddRule(Industry.new(area))
        queue.AddRule(Upkeep.new(area))
      }

      # TradePrices
      @state.each_trade_node.each { | area |
        queue.AddRule(TradePrices.new(area.trade_node))
      }

      # loyalty

      # development

      # prosperity

      # uprisings

      # wars - start, continue, end

      # population growth

      # migration - prosperity causes pull from rural to urban, development causes pull

      # sieges

      # battles - details are written to game file so can be reported and cleared in new_turn



      # rules for each ship
      # game.each_ship { | ship |

      #   # add a combat rule for every construct (so they LOOK for combat)
      #   combR = rf.CreateRule("combat", {"ship" => ship}, ship.player, game)
      #   queue.AddRule(combR) if combR != nil

      #   # ships with waypoints - but no move order, need one generated for them!

      #     # check if ship has a waypoint
      #     if ship.waypointX != ship.x or ship.waypointY != ship.y

      #     # does this ship already have a move order?
      #     has_rule = false
      #     queue.each { | rule |
      #       if rule.class == MoveRule
      #         if rule.ship == ship.gameId.to_s or rule.ship == ship.name
      #           has_rule = true
      #         end
      #       end
      #     }

      #     # if ship has no move rule (but a none blank waypoint) then add one
      #     if !has_rule and ship.waypointX and ship.waypointY
      #       automove = MoveRule.new(ship.player)
      #       automove.ship = ship.gameId.to_s
      #       automove.x = ship.waypointX.to_s
      #       automove.y = ship.waypointY.to_s
      #       queue.AddRule(automove)
      #     end
      #     end
      # }

    # rules for each planet
    # game.each_planet { | planet |
    #   # add a mining rule for every populated planet
    #   if planet.player != nil
    #     minR = rf.CreateRule("mining", {"planet" => planet}, planet.player, game)
    #     queue.AddRule(minR) if minR != nil
    #   end
    # }

      # rules for each faction
      # game.each_faction { | faction |
      #     r = rf.CreateRule("discovery", nil, faction.gameId, game)
      #     queue.AddRule(r) if r != nil
      # }

      # sort rule queue
      puts "sorting rule queue"
      queue.Sort

      # evaluate rules one at a time, allowing rules to create new rules
      puts "evaluating rules"
      while queue.More?

        rule = queue.Next
        queue.Insert rule.execute(@state)
      end

      puts "trade value of each node"
      @state.each_trade_node.each { | area |
        puts "#{area.trade_node.name}, value=#{area.trade_node.trade_value}"
      }

      # save game file
      #puts "## skipping save in dev ##"
      @state.save gamefile

      # produce reports
      puts "producing player reports"
      reports = ReportGenerator.new reportsdir
      @state.each_player { | player, kingdom |
        reports.run @state, player
      }
    end
  end
end
