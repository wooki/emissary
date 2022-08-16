require_relative './area'
require_relative './store'

module Emissary

class Settlement < Area

  attr_accessor :shortcut, :shortcut_help, :owner, :trade, :store

  def initialize
    super()
    @store = Store.new
  end

  def name
    @name
  end

  def name=(val)
    @name = val
  end

end

end
