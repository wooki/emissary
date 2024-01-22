require 'json'

module Emissary
  class Message
    attr_accessor :player, :message, :from

    def initialize
      super()
    end

    def as_json(_options = {})
      {
        player: @player,
        from: @from,
        message: @message
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
