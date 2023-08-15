module Emissary

class TradeNode

  attr_accessor :name, :connected, :is_node, :prices, :trade_value

  def initialize
    super()
    @connected = Hash.new
    @is_node = true
    @prices = Hash.new
    @orders = Hash.new # temporary during turn, keep track for setting prices
    @trade_value = 0
  end

  # calcluate a price based on demand
  def commodity_price(buy, sell)
    demand = sell - buy
    base_price = 1.0 # price when buy=sell
    max_qty = 1000.0
    curve_factor = 32.0 #64.0
    price = base_price * (curve_factor ** -(demand.to_f/max_qty))
    price = 0.01 if price < 0.01
    price.round(2)
  end

  def new_turn
    @prices = {food: 1.0, goods: 1.0} if !@prices or @prices.keys.length == 0

    @orders = Hash.new
    @orders[:food] = {buy: 0, sell: 0}
    @orders[:goods] = {buy: 0, sell: 0}
  end

  # buy/sell_later registers the trade and effects the price
  # but does not return a price
  def buy_later(commodity, n)
    @orders[commodity][:buy] += n
  end

  def sell_later(commodity, n)
    @orders[commodity][:sell] += n
  end

  # get price for n
  def price(commodity, n)
    (@prices[commodity] * n).round(0)
  end

  # cost of trading with a specific urban area based on the distance
  def trade_percentage(urban)
    return 0 if !urban.trade
    TRADE_RATE + (TRADE_RATE_TRAVEL * urban.trade.distance)
  end

  # sets the price based on quantity being traded
  def set_prices

    # also look at connected trade nodes

    # for connected node split surplus buys/sells across all nodes connected to that node
    # and add to this node for this calculation. Further decrease surplus based on distance
    self.food_price = self.commodity_price(@orders[:food][:buy], @orders[:food][:sell])
    self.goods_price = self.commodity_price(@orders[:goods][:buy], @orders[:goods][:sell])
  end

  def food_price
    return @prices[:food] if @prices[:food]
    1.0
  end

  def food_price=(price)
    @prices[:food] = price
  end

  def goods_price
    return @prices[:goods] if @prices[:goods]
    1.0
  end

  def goods_price=(price)
    @prices[:goods] = price
  end

  def add_trade_value(value)
    @trade_value = @trade_value + value
  end

end

end
