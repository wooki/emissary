module Emissary

class TradeNode

  attr_accessor :name, :connected, :is_node

  def initialize
    super()
    @connected = Hash.new    
    @is_node = true
  end  

end

end
