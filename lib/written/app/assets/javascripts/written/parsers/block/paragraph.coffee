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

  markdown: =>
    node = "<p>".toHTML()
    for text in @content
      if text.markdown?
        node.appendChild(text.markdown())
      else
        node.appendChild(document.createTextNode(text))

    node

  html: =>
    node = "<p>".toHTML()
    for text in @content
      if text.html?
        node.appendChild(text.html())
      else
        node.appendChild(document.createTextNode(text))

    node



Paragraph.rule = /.*/i

Written.Parsers.register {
  parser: Paragraph
  node: 'p'
  type: 'block'
  default: true
  getRange: (node, offset, walker) ->
    range = document.createRange()

    if !node.firstChild?
      range.setStart(node, 0)
    else
      while walker.nextNode()
        if walker.currentNode.length < offset
          offset -= walker.currentNode.length
          continue

        range.setStart(walker.currentNode, offset)
        break

    range.collapse(true)
    range

  toString: (node) ->
    node.textContent

}
