#= require 'written'
#= require 'prism'
#
document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

element = document.getElementById('Editor')
if element?
  parsers = new Written.Parsers()

  parsers.get('pre')?.highlightWith (element) ->
    Prism.highlightElement(element, false)

  parsers.get('code')?.highlightWith (element) ->
    Prism.highlightElement(element, false)

  editor = new Written(element, {
    parsers: parsers
  })
