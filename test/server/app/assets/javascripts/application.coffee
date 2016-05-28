#= require 'written'
#= require 'prism'
#
document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

blocks = Written.Parsers.Blocks.select('pre','h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'blockquote')
inlines = Written.Parsers.Inlines.select('strong', 'em', 'code')

parsers = new Written.Parsers()

parsers.get('pre').highlightWith (element) ->
  Prism.highlightElement(element, false)

parsers.get('code').highlightWith (element) ->
  Prism.highlightElement(element, false)

editor = new Written(document.getElementById('Editor'), {
  parsers: parsers
})
