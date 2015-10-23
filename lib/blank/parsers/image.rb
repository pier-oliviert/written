module Blank::Parsers
  class Image < Base
    RULE = /^(!{1}\[([^\]]+)\])(\(([^\s]+)?\))$/i

    def parse!

      unless @node.instance_of?(Blank::Node)
        return @node
      end

      if match = RULE.match(@node.content)
        @node = Blank::Nodes::Image.new(match[2], match[4])
        @document.nodes[@index] = @node
      end
      return @node
    end
  end
end

