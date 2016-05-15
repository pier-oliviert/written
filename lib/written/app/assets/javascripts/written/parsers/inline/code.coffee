class Code
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    node = "<code>#{this.match[0]}</code>".toHTML()
    if @match[3]?
      node.classList.add("language-#{@match[3]}")

    if @highlight?
      @highlight(node)
    node

  html: =>
    node = "<code>#{this.match[4]}</code>".toHTML()
    if @match[3]?
      node.classList.add("language-#{@match[3]}")

    node


Code.rule = /((~{3})([a-z]+)?)\s(.+)?(~{3})/gi

Written.Parsers.register {
  parser: Code
  node: 'code'
  type: 'inline'
  getRange: (node, offset, walker) ->
    range = document.createRange()

    if !@firstChild?
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

  highlightWith: (callback) ->
    Code.prototype.highlight = callback
}
