module Wraithdale
  
class Kingdom
  
  attr_accessor :belongs_to, :name, :capital, :capital_coord
  
  ##################################
  # set-up initial state
  ##################################
  def initialize
    super()
    
    @belongs_to = nil # user_id
    @name = nil
    @capital = nil
    @capital_coord = {:x => nil, :y => nil}
    
  end



end
  
end
