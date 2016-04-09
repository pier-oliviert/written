class Paragraph
  constructor: (match) ->
    @match = match
    @node = "<p>".toHTML()

  render: (str) =>
    @node.textContent = str
    @node

  toHTMLString: (node) ->
    text = ''
    child = node.firstChild
    while child
      if child.toHTMLString
        text += child.toHTMLString()
      else
        text += child.toString()
      child = child.nextSibling

    "<p>#{text}</p>"

Written.Parsers.Block.register Paragraph, /.*/i, true
