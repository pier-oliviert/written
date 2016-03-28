module Written
  autoload :Document, 'written/document'
  autoload :Version,  'written/version'

  def self.parse(str)
    document = Document.new(str)
    document.parse!
    document
  end
end

if defined?(Rails)
  require 'written/railtie'
end
