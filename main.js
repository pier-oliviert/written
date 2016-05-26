document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

Written.Parsers.get('pre').highlightWith(function(element) {
  Prism.highlightElement(element, false)
})

Written.Parsers.get('code').highlightWith(function(element) {
  Prism.highlightElement(element, false)
})

var el = document.querySelector('main')

editor = new Written(el)
editor.initialize()
