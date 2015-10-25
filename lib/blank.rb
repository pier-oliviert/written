module Blank
  autoload :Document, 'blank/document'

  def self.parse(str)
    document = Document.new(str)
    document.parse!
    document
  end
end

if defined?(Rails)
  require 'blank/railtie'
end
