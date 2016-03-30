class Link
  constructor: (match) ->
    @match = match
    @node = "<a>".toHTML()

  render: (textNode) =>
    @node.href = @match[4]
    name = "<strong>".toHTML()
    anchor = textNode.splitText(textNode.textContent.indexOf(@match[0]))
    anchor.splitText(@match[0].length)
    name.textContent = @match[1]
    @node.appendChild(name)
    @node.appendChild(document.createTextNode(@match[3]))
    textNode.parentElement.replaceChild(@node, anchor)

Written.Parsers.Inline.register Link, /!{0}(\[([^\]]+)\])(\(([^\)]+)\))/gi
