module Emissary
  require 'json'

  class Report
    attr_accessor :kingdoms, :map, :my_kingdom, :turn, :errors, :messages

    def initialize
      super()

      # keyed by user id
      @kingdoms = {}
      @my_kingdom = nil

      # keyed by "x,y" (areas contain units)
      @map = {}

      @turn = 0
      @errors = []
      @messages = []
    end

    def as_json(_options = {})
      # :kingdoms, :map, :my_kingdom
      data = {
        kingdoms: @kingdoms,
        map: @map,
        errors: @errors,
        messages: @messages,
        turn: @turn
      }
      data[:my_kingdom] = @my_kingdom unless @my_kingdom.nil?
      data
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
