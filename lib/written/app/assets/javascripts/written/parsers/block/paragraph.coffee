class Paragraph
  multiline: false

  constructor: (match) ->
    @match = match

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  text: =>
    @match[0]

  raw: =>
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
  node: 'p'
  type: 'block'
  rule: /.*/i
  default: true
}
