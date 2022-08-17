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

    def More?
      @rules.length > 0
    end

    def Next
      @rules.shift
    end

    def Insert(rules)

      return nil if !rules or rules.length == 0

      rules = [rules] if rules.is_a?(Rule)
      return nil if !rules.is_a?(Array)

      # insert in correct position, don't want to resort a sorted array
      rules.each { | rule |
        if rule.is_a?(Rule)
          position = rules.index { | x | x.turnSequence > rule.turnSequence }
          if position
            @rules.insert(position, rule)
          else
            self.AddRule rule
          end
        end
      }
    end

    # index by int
    # def [](key)
    #   return @rules[key]
    # end

    # iterator
    # def each
    #   for i in 0...@rules.size
    #     yield(@rules[i])
    #   end
    # end

  end

end