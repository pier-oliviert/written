#= require 'written'
#= require 'prism'
#
document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

parsers = new Written.Parsers({blocks: ['header', 'code', 'image', 'ulist', 'olist', 'quote'], inlines: ['strong', 'italic', 'code', 'link']})

parsers.get('pre')?.highlightWith (element) ->
  Prism.highlightElement(element, false)

parsers.get('code')?.highlightWith (element) ->
  Prism.highlightElement(element, false)

editor = new Written(document.getElementById('Editor'), {
  parsers: parsers
})
