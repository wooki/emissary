require_relative '../rulesengine/rule'
require_relative '../rulesengine/turn_sequence'

class SetTradePolicy < Rule
  attr_accessor :settlement, :resource, :policy

  def initialize(player)
    super(player, TS_SET_TRADE_POLICY)
  end

  # executes this rule against the gamestate
  def Execute(game)
    # get the faction
    faction = game.factions[@factionId]

    # message
    game.OrderError(@factionId, "build order failed faction did not have the required cost of #{cost} energy")

    game.add_message('build',
                     :host,
                     @factionId,
                     "#{builder.name} has built a new #{ship.hullclass(game)} class ship, The #{ship.name}")
  end
end
