lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'written/version'

Gem::Specification.new do |s|
  s.name        = 'written'
  s.version     = Written::VERSION
  s.summary     = "HTML and Ruby Markdown Editor"
  s.description = "Written is a rich Markdown editor for the web."
  s.authors     = ["Pier-Olivier Thibault"]
  s.email       = 'pothibo@gmail.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.require_path = 'lib'
  s.homepage    = 'https://github.com/pothibo/written'
  s.license     = 'MIT'
end
