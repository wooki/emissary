require_relative './area'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :trade, :store

  def initialize
    super()  
  end

end

end
