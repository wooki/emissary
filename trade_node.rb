module Emissary

class TradeNode

  attr_accessor :name, :connected, :is_node, :prices

  def initialize
    super()
    @connected = Hash.new
    @is_node = true
    @prices = Hash.new
    @orders = Hash.new # temporary during turn, keep track for setting prices
  end

  # calcluate a price based on demand
  def commodity_price(buy, sell)
    demand = sell - buy
    base_price = 1.0 # price when buy=sell
    max_qty = 100.0
    curve_factor = 64.0
    price = base_price * (curve_factor ** -(demand.to_f/max_qty))
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
    puts "buy later #{commodity} #{n} #{@orders.inspect}"
    @orders[commodity][:buy] += n
  end

  def sell_later(commodity, n)
    @orders[commodity][:sell] += n
  end

  # get price for n
  def price(commodity, n)
    (@prices[commodity] * n).round(0)
  end

  # sets the price based on quantity being traded
  def setPrices(food, goods)
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

end

end