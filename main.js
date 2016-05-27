document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

Written.Parsers.get('pre').highlightWith(function(element) {
  Prism.highlightElement(element, false)
})

Written.Parsers.get('code').highlightWith(function(element) {
  Prism.highlightElement(element, false)
})

var main = document.querySelector('main')
var Editor = document.querySelector('#Editor')
var Rendered = document.querySelector('#Rendered')
var toggles = Array.prototype.slice.call(document.querySelectorAll('nav > a'))
var written = new Written(Editor)

written.initialize()

toggles[0].addEventListener('click', function(e) {
  if (Editor.parentElement == null) {
    Rendered.remove()
    main.appendChild(Editor)
    delete e.target.parentElement.querySelector('[data-selected]').dataset.selected
    e.target.dataset.selected = true
  }
})

toggles[1].addEventListener('click', function(e) {
  if (Rendered.parentElement == null) {
    Editor.remove()
    main.appendChild(Rendered)
    delete e.target.parentElement.querySelector('[data-selected]').dataset.selected
    e.target.dataset.selected = true
  }
})

Editor.addEventListener('written:changed', function() {
  Rendered.innerHTML = written.history.current.toHTMLString()
  Array.prototype.slice.call(Rendered.querySelectorAll('code')).forEach(function(code) {
    Prism.highlightElement(code, false)
  })
})

Rendered.innerHTML = written.history.current.toHTMLString()
Array.prototype.slice.call(Rendered.querySelectorAll('code')).forEach(function(code) {
    Prism.highlightElement(code, false)
  })
Rendered.remove()
