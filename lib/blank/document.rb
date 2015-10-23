require 'blank/parsers'
require 'blank/node'

module Blank
  class Document

    attr_reader :nodes

    def initialize(content)
      @nodes = content.lines.map do |text|
        Node.new(text.chomp)
      end
    end

    def parsers
      [
        Blank::Parsers::Code,
        Blank::Parsers::Heading,
        Blank::Parsers::Image,
        Blank::Parsers::List,
        Blank::Parsers::Word,
        Blank::Parsers::Link
      ]
    end

    def parse!
      parsers.each do |parser|
        parser.parse!(self)
      end
    end

    def to_html
      @nodes.map do |node|
        if node.instance_of?(Blank::Node)
          "<p>#{node.to_s}</p>"
        else
          node.to_s
        end
      end.join
    end
  end
end
