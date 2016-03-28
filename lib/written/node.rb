module Written
  module Nodes
    autoload :Image,                   'written/nodes/image'
    autoload :UnorderedList,           'written/nodes/unordered_list'
    autoload :OrderedList,             'written/nodes/ordered_list'
    autoload :Code,                    'written/nodes/code'
    autoload :Heading,                 'written/nodes/heading'
  end

  class Node
    attr_accessor :content

    def initialize(content)
      @content = content || String.new
    end

    def to_s
      @content
    end
  end
end
