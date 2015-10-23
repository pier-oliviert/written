module Blank
  module Nodes
    autoload :Image,                   'blank/nodes/image'
    autoload :UnorderedList,           'blank/nodes/unordered_list'
    autoload :OrderedList,             'blank/nodes/ordered_list'
    autoload :Code,                    'blank/nodes/code'
    autoload :Heading,                 'blank/nodes/heading'
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
