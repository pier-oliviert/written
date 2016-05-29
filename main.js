document.removeEventListener('DOMContentLoaded', Prism.highlightAll)

Array.prototype.slice.call(document.querySelectorAll('main > section')).forEach( function(section) {
  var editor = section.querySelector('.editor')
  var rendered = section.querySelector('.rendered')
  var toggles = Array.prototype.slice.call(section.querySelectorAll('nav > a'))
  var blocks, inlines

  if (editor.dataset.blocks) {
    blocks = Written.Parsers.Blocks.select.apply(Written.Parsers.Blocks, editor.dataset.blocks.split(','))
  }

  if (editor.dataset.inlines) {
    inlines = Written.Parsers.Inlines.select.apply(Written.Parsers.Inlines, editor.dataset.inlines.split(','))
  }

  parsers = new Written.Parsers(blocks, inlines)

  if (parsers.get('pre')) {
    parsers.get('pre').highlightWith(function(element) {
      Prism.highlightElement(element, false)
    })
  }

  if (parsers.get('code')) {
    parsers.get('code').highlightWith(function(element) {
      Prism.highlightElement(element, false)
    })
  }


  var written = new Written(editor, {parsers: parsers})

  toggles[0].addEventListener('click', function(e) {
    if (editor.parentElement == null) {
      section.insertBefore(editor, rendered)
      rendered.remove()
      delete e.target.parentElement.querySelector('[data-selected]').dataset.selected
      e.target.dataset.selected = true
    }
  })

  toggles[1].addEventListener('click', function(e) {
    if (rendered.parentElement == null) {
      section.insertBefore(rendered, editor)
      editor.remove()
      delete e.target.parentElement.querySelector('[data-selected]').dataset.selected
      e.target.dataset.selected = true
    }
  })

  editor.addEventListener('written:changed', function() {
    rendered.innerHTML = written.history.current.toHTMLString()
    Array.prototype.slice.call(rendered.querySelectorAll('code')).forEach(function(code) {
      Prism.highlightElement(code, false)
    })
  })

  rendered.innerHTML = written.history.current.toHTMLString()
  Array.prototype.slice.call(rendered.querySelectorAll('code')).forEach(function(code) {
      Prism.highlightElement(code, false)
    })

  editor.remove()
});

Array.prototype.slice.call(document.querySelectorAll('pre[data-highlight=true]')).forEach(function(block) {
  Prism.highlightElement(block, false)
})
