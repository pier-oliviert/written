#= require 'written'
#= require 'prism'
#
document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

element = document.getElementById('Editor')
if element?
  parsers = new Written.Parsers({blocks: ['header', 'code', 'image', 'ulist', 'olist', 'quote'], inlines: ['bold', 'italic', 'code', 'link']})

  parsers.get('pre')?.highlightWith (element) ->
    Prism.highlightElement(element, false)

  parsers.get('code')?.highlightWith (element) ->
    Prism.highlightElement(element, false)

  editor = new Written(element, {
    parsers: parsers
  })
