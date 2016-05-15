class Italic
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    "<em>#{this.match[1]}</em>".toHTML()

  html: ->
    "<em>#{this.match[3]}</em>".toHTML()

Italic.rule = /((_{1})([^_]+)(_{1}))/gi


Written.Parsers.register {
  parser: Italic
  node: 'em'
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
