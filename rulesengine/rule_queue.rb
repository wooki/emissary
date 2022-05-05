module Emissary

  class RuleQueue

    def initialize
      @rules = Array.new
    end

    def AddRule(rule)
      @rules.push(rule)
    end

    # sorts orders into sequence order
    def Sort
      @rules.sort!
    end

    # index by int
    def [](key)
      return @rules[key]
    end

    # iterator
    def each
      for i in 0...@rules.size
        yield(@rules[i])
      end
    end

  end

end