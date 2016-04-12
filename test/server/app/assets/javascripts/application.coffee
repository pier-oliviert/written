#= require 'written'
#= require 'prism'

Written.Parsers.Block.get('Code').parseSyntax = (element) ->
  Prism.highlightElement(element, false)

Written.Parsers.Inline.get('Code').parseSyntax = (element) ->
  Prism.highlightElement(element, false)

editor = new Written(document.getElementById('Editor'))
editor.initialize()
