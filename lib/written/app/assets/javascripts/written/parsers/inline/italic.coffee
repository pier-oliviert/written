class Italic
  constructor: (match) ->
    @match = match
    @node = "<em>".toHTML()

  render: (textNode) =>
    italic = textNode.splitText(textNode.textContent.indexOf(@match[0]))
    italic.splitText(@match[0].length)
    @node.appendChild(document.createTextNode(@match[0]))
    textNode.parentElement.replaceChild(@node, italic)

Written.Parsers.Inline.register Italic, /(([^\*]\*{1})[^\*]+(\*{1}[^\*]))/gi

