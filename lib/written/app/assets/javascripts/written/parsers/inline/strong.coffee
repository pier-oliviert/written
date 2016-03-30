class Strong
  constructor: (match) ->
    @match = match
    @node = "<strong>".toHTML()

  render: (textNode) =>
    strong = textNode.splitText(textNode.textContent.indexOf(@match[0]))
    strong.splitText(@match[0].length)
    @node.appendChild(document.createTextNode(@match[0]))
    textNode.parentElement.replaceChild(@node, strong)

Written.Parsers.Inline.register Strong, /((\*{2})[^\*]+(\*{2}))/gi
