module Emissary

class Store

  attr_accessor :food, :goods, :gold

  def initialize
    super()
    @food = 0
    @goods = 0
    @gold = 0
  end

  def trade_food(food, cost)
    @food = @food + food
    @gold = @gold - cost
  end

  def trade_goods(goods, cost)
    @goods = @goods + goods
    @gold = @gold - cost
  end

end

end
