class Italic
  constructor: (match) ->
    @match = match
    @node = "<em>".toHTML()
    @node.toHTMLString = @toHTMLString.bind(@node)

  render: (textNode) =>
    italic = textNode.splitText(textNode.textContent.indexOf(@match[2]))
    italic.splitText(@match[2].length)
    @node.appendChild(document.createTextNode(@match[2]))
    textNode.parentElement.replaceChild(@node, italic)

    @node

  toHTMLString: (node) ->
    "<em>#{node.toString().slice(1,-1)}</em>"

Written.Parsers.Inline.register Italic, /(\s|^|\d)(\*{1}([^\*]+)\*{1})/gi

