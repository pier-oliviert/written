module Written::Parsers
  class Image < Base
    RULE = /^(!{1}\[([^\]]+)\])(\(([^\s]+)?\))$/i

    def parse!

      unless @node.instance_of?(Written::Node)
        return @node
      end

      if match = RULE.match(@node.content)
        @node = Written::Nodes::Image.new(match[2], match[4])
        @document.nodes[@index] = @node
      end
      return @node
    end
  end
end

