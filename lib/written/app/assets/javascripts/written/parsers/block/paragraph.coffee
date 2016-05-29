class Paragraph extends Written.Parsers.Block
  multiline: false

  constructor: (match) ->
    @match = match

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  innerText: =>
    @match[0]

  outerText: =>
    @match[0]

  toEditor: =>
    node = Written.toHTML("<p>")
    for text in @content
      if text.toEditor?
        node.appendChild(text.toEditor())
      else
        node.appendChild(document.createTextNode(text))

    node

  toHTML: =>
    node = Written.toHTML("<p>")
    for text in @content
      if text.toHTML?
        node.appendChild(text.toHTML())
      else
        node.appendChild(document.createTextNode(text))

    node



Written.Parsers.register {
  parser: Paragraph
  name: 'paragraph'
  nodes: ['p']
  type: 'block'
  rule: /.*/i
  default: true
}
