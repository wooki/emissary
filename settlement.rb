require_relative './area'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :trade, :store

  def initialize
    super()
  end

  def name
    @name
  end

  def name=(val)
    @name = val
  end

end

end
