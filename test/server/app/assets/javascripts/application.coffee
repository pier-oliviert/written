#= require 'written'
#= require 'prism'
#
document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

parsers = new Written.Parsers({blocks: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'figure', 'pre', 'blockquote'], inlines: ['strong', 'em', 'code', 'a']})

parsers.get('pre')?.highlightWith (element) ->
  Prism.highlightElement(element, false)

parsers.get('code')?.highlightWith (element) ->
  Prism.highlightElement(element, false)

editor = new Written(document.getElementById('Editor'), {
  parsers: parsers
})
