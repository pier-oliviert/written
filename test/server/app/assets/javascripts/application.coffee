#= require 'written'
#= require 'prism'

Written.Parsers.Block.get('Code').parseSyntax = (element) ->
  Prism.highlightElement(element, false)

new Written(document.getElementById('Editor'))
