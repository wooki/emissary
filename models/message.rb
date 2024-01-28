require 'json'

module Emissary
  class Message
    attr_accessor :message, :from

    def initialize(message, from)
      super()
      @message = message
      @from = from
    end

    def as_json(options = {})
      {
        from: @from,
        message: @message
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
