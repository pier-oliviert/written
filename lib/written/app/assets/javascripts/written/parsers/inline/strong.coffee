class Strong
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    "<strong>#{@match[0]}</strong>".toHTML()

  html: =>
    "<strong>#{@match[3]}</strong>".toHTML()

Strong.rule = /((\*{1})([^\*]+)(\*{1}))/gi

Written.Parsers.register {
  parser: Strong
  node: 'strong'
  type: 'inline'
  getRange: (node, offset, walker) ->
    range = document.createRange()

    if !node.firstChild?
      range.setStart(this, 0)
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
