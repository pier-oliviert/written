#= require 'written'
#= require 'prism'
#
document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

Written.Parsers.get('pre').highlightWith (element) ->
  Prism.highlightElement(element, false)

Written.Parsers.get('code').highlightWith (element) ->
  Prism.highlightElement(element, false)

editor = new Written(document.getElementById('Editor'))
editor.initialize()


