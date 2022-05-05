require_relative 'order_parser'

module Emissary

  # runs a turn
  class Turn

  def initialize(gamefile, ordersdir, randomseed)

      # get the game
      @state = Emissary::GameState.load(gamefile)

      # clear old data
      @state.new_turn(randomseed)

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

      # add system orders for ships. factions and planets
      puts "adding system rules"
      rf = RuleFactory.new

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

      # evaluate rules
      puts "evaluating rules"
      queue.each { | rule |
        rule.Execute(game)
      }

      # save game file
      @state.save gamefile

    end
  end
end
