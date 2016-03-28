require 'written/parsers'
require 'written/node'

module Written
  class Document

    attr_reader :nodes

    def initialize(content)
      @nodes = content.lines.map do |text|
        Node.new(text.chomp)
      end
    end

    def parsers
      [
        Written::Parsers::Code,
        Written::Parsers::Heading,
        Written::Parsers::Image,
        Written::Parsers::List,
        Written::Parsers::Word,
        Written::Parsers::Link
      ]
    end

    def parse!
      parsers.each do |parser|
        parser.parse!(self)
      end
    end

    def to_html
      @nodes.map do |node|
        if node.instance_of?(Written::Node)
          "<p>#{node.to_s}</p>"
        else
          node.to_s
        end
      end.join
    end
  end
end
